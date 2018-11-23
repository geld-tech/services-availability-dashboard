#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Services Availability API and Dashboard
    Display services metrics and provides REST API back-end
"""
import ast
import base64
import ConfigParser
from codecs import encode
import datetime
import logging
import logging.handlers
from optparse import OptionParser
import os
from flask import Flask, jsonify, render_template, request

from modules.ServiceStatus import ServiceStatus
from modules.Models import Base, Server, Service, Metrics

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)
app.url_map.strict_slashes = False
app.debug = True

# Global config
config_file = 'config/settings.cfg'

# Initialisation
logging.basicConfig(format='[%(asctime)-15s] [%(threadName)s] %(levelname)s %(message)s', level=logging.INFO)
logger = logging.getLogger('root')

nginx_status = ServiceStatus()

# DB Session
db_path = os.path.dirname(os.path.abspath(__file__))+'/data/metrics.sqlite3'
engine = create_engine('sqlite:///'+db_path)
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
db_session = DBSession()


@app.route("/")
def index():
    global config_file
    try:
        settings = {'firstSetup': True}
        ganalytics_id = False

        if os.path.isfile(config_file):
            settings = {'firstSetup': False}
            config = ConfigParser.ConfigParser()
            config.readfp(open(config_file))
            if 'ganalytics' in config.sections():
                ganalytics_id = config.get('ganalytics', 'ua_id')

        return render_template('index.html', settings=settings, ga_ua_id=ganalytics_id)
    except Exception, e:
        logger.error('Error serving web application: %s' % e)
        return jsonify({'data': {}, 'error': 'Could serve web application, check logs for more details..'}), 500


@app.route("/api/services/status", strict_slashes=False)
def status():
    try:
        data = []
        time_labels = []
        now = datetime.datetime.utcnow()
        last_2_hours = now - datetime.timedelta(hours=2)

        server = db_session.query(Server).filter_by(hostname=nginx_status.get_server_hostname()).first()
        for result in db_session.query(Service).filter_by(server=server).order_by(Service.id):
            for metric in db_session.query(Metrics).filter_by(service=result.service).filter(Metrics.timestamp >= last_2_hours.strftime('%s')).order_by(Metrics.id):
                status = {}
                status['uri'] = result.uri
                status['latency'] = metric.latency
                status['available'] = metric.available
                status['date_time'] = metric.date_time.strftime("%H:%M")
                data.append(status)
                time_labels.append(result.date_time)
        return jsonify({'data': data, 'time_labels': time_labels}), 200
    except Exception, e:
        logger.error('Error retrieving services status: %s' % e)
        return jsonify({'data': {}, 'error': 'Could not retrieve nginx status, check logs for more details..'}), 500


@app.route("/setup/password", methods=['POST'])
@app.route("/setup/password/", methods=['POST'])
def set_password(password=None):
    if request.method == 'POST':
        data = ast.literal_eval(request.data)
        if 'password' in data:
            password = sanitize_user_input(data['password'])
            if store_password(password):
                return jsonify({"data": {"response": "Success!"}}), 200
            else:
                return jsonify({"data": {}, "error": "Could not set password"}), 500
        else:
            return jsonify({"data": {}, "error": "Password needs to be specified"}), 500
    else:
        return jsonify({"data": {}, "error": "Password can not be empty"}), 500


def store_password(password):
    global config_file
    try:
        with open(config_file, 'ab') as outfile:
            config = ConfigParser.ConfigParser()
            config.add_section('admin')
            config.set('admin', 'password', obfuscate(password))
            config.write(outfile)
        return True
    except Exception:
        return False


@app.route("/setup/ganalytics", methods=['POST'])
@app.route("/setup/ganalytics/<ua_id>", methods=['POST'])
def set_ganalytics(ua_id=None):
    if request.method == 'POST':
        data = ast.literal_eval(request.data)
        if 'uaid' in data:
            ua_id = sanitize_user_input(data['uaid'])
            if store_ua_id(ua_id):
                return jsonify({"data": {"response": "Success!"}}), 200
            else:
                return jsonify({"data": {}, "error": "Could not set UA ID"}), 500
        else:
            return jsonify({"data": {}, "error": "Google Analytics User Agent ID needs to be specified"}), 500
    else:
        return jsonify({"data": {}, "error": "UA ID can not be empty"}), 500


def store_ua_id(ua_id):
    global config_file
    try:
        with open(config_file, 'ab') as outfile:
            config = ConfigParser.ConfigParser()
            config.add_section('ganalytics')
            config.set('ganalytics', 'ua_id', ua_id)
            config.write(outfile)
        return True
    except Exception:
        return False


@app.route("/setup/services", methods=['POST'])
@app.route("/setup/services/", methods=['POST'])
def set_services(services=[]):
    if request.method == 'POST':
        services = request.data
        if services:
            if store_services(services):
                return jsonify({"data": {"response": "Success!"}}), 200
            else:
                return jsonify({"data": {}, "error": "Could not set services"}), 500
        else:
            return jsonify({"data": {}, "error": "Services can not be empty"}), 500
    else:
        services = get_services()
        if services:
            return jsonify({"data": {"response": "Success!"}, "services": services}), 200
        else:
            return jsonify({"data": {}, "error": "Could not get services"}), 500


def get_services():
    global config_file
    try:
        with open(config_file, 'r') as infile:
            config = ConfigParser.ConfigParser()
            config.read(infile)
            return config.get_section('services')
        return True
    except Exception:
        return False


def store_services(services):
    global config_file
    try:
        services = ast.literal_eval(services)
        with open(config_file, 'ab') as outfile:
            config = ConfigParser.ConfigParser()
            config.add_section('services')
            for service in services.get('services', []):
                config.set('services', service.get('name'), '%s:%s' % (service.get('url'), service.get('port')))
            config.write(outfile)
        return True
    except Exception, e:
        logger.error('Error while storing services: %s' % e)
        logger.error('Services: %s' % services)
        return False


def sanitize_user_input(word):
    black_list = ['__import__', '/', '\\', '&', ';']
    for char in black_list:
        word = word.replace(char, '')
    return word


def obfuscate(text, decode=False):
    try:
        if decode:
            return base64.b64decode(decode(text, 'rot13'))
        else:
            return base64.b64encode(encode(text, 'rot13'))
    except Exception, e:
        logger.error('Error while encoding or decoding text: %s' % e)
        return text


@app.errorhandler(404)
def page_not_found(e):
    return jsonify({"data": "not found", "error": "resource not found"}), 404


if __name__ == "__main__":
    # Parse options
    opts_parser = OptionParser()
    opts_parser.add_option('--debug', action='store_true', dest='debug', help='Print verbose output.', default=False)
    options, args = opts_parser.parse_args()
    if options.debug:
        logger.setLevel(logging.DEBUG)
        logger.debug('Enabled DEBUG logging level.')
    logger.info('Options parsed')
    app.run(host='0.0.0.0')
