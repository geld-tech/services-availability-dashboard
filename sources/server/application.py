#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Services Availability API and Dashboard
    Display services metrics and provides REST API back-end
"""
import ast
import base64
import ConfigParser
import datetime
import logging
import logging.handlers
import os
import sys
from codecs import encode
from functools import wraps
from optparse import OptionParser

from flask import Flask, jsonify, render_template, request, session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from modules.Models import Base, Metrics
from modules.ServiceStatus import ServiceStatus

# Global config
local_path = os.path.dirname(os.path.abspath(__file__))
config_file = local_path+'/config/settings.cfg'
secret_key = os.urandom(24)

# Flask Initialisation
app = Flask(__name__)
app.url_map.strict_slashes = False
app.debug = True
app.secret_key = secret_key

# Initialisation
logging.basicConfig(format='[%(asctime)-15s] [%(threadName)s] %(levelname)s %(message)s', level=logging.INFO)
logger = logging.getLogger('root')

service_status = ServiceStatus()

# DB Session
db_path = local_path+'/data/metrics.sqlite3'
engine = create_engine('sqlite:///'+db_path)
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
db_session = DBSession()


def authenticated(func):
    """Checks whether user is logged in or raises error 401."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        if session.get('admin_user', False):
            return func(*args, **kwargs)
        else:
            return jsonify({"data": {}, "error": "Authentication required.", "authenticated": False}), 401
    return wrapper


@app.route("/")
def index():
    global config_file
    try:
        ganalytics_id = ''
        if os.path.isfile(config_file):
            settings = {'firstSetup': False}
            config = ConfigParser.ConfigParser()
            config.readfp(open(config_file))
            if 'ganalytics' in config.sections():
                ganalytics_id = config.get('ganalytics', 'ua_id')
        else:
            settings = {'firstSetup': True}
            # Bypass authentication during first setup
            session.clear()
            session['admin_user'] = True

        return render_template('index.html', settings=settings, ga_ua_id=ganalytics_id)
    except Exception, e:
        logger.error('Error serving web application: %s' % e)
        return jsonify({'data': {}, 'error': 'Could serve web application, check logs for more details..'}), 500


@app.route("/api/services/status", strict_slashes=False)
def status():
    try:
        services = []
        datasets = []
        data = []
        time_labels = []
        xaxis_labels = []
        now = datetime.datetime.utcnow()
        last_2_hours = now - datetime.timedelta(hours=2)
        colors = colors_generator()

        for service in db_session.query(Metrics.service_name).distinct().all():
            service = ''.join(service)
            services.append(service)

        for service in services:
            dataset = {}
            dataset["label"] = service
            dataset["colors"] = next(colors)
            dataset["data"] = []
            dataset["availability"] = []
            for service_metrics in db_session.query(Metrics).filter(Metrics.service_name == service).filter(Metrics.timestamp >= last_2_hours.strftime('%s')).order_by(Metrics.timestamp.desc()).limit(90):
                xaxis_label = service_metrics.date_time.strftime("%H:%M")
                if xaxis_label not in xaxis_labels:
                    xaxis_labels.append(xaxis_label)
                dataset["data"].append(service_metrics.latency)
                dataset["availability"].append(service_metrics.available)
            datasets.append(dataset)

        for metric in db_session.query(Metrics).filter(Metrics.timestamp >= last_2_hours.strftime('%s')).order_by(Metrics.id):
            status = {}
            status['name'] = metric.service_name
            status['latency'] = metric.latency
            status['available'] = metric.available
            status['date_time'] = metric.date_time.strftime("%H:%M")
            data.append(status)

        return jsonify({'labels': xaxis_labels,
                        'datasets': datasets,
                        'data': data,
                        'time_labels': time_labels,
                        'services':
                        {'names': services,
                         'metrics': data}}), 200
    except Exception, e:
        exc_type, exc_obj, exc_tb = sys.exc_info()
        del exc_type
        del exc_obj
        logger.error('Error retrieving services status (line %d): %s' % (exc_tb.tb_lineno, e))
        return jsonify({'data': {}, 'error': 'Could not retrieve service status, check logs for more details..'}), 500


@app.route("/setup/password/", methods=['POST'], strict_slashes=False)
@authenticated
def set_password():
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
        return jsonify({"data": {}, "error": "Incorrect request method"}), 500


def colors_generator():
    colors = ["#3E95BC", "#8E5EA2", "#3CBA9F", "#E8C3B9", "#C45850",
              "#FF6384", "#36A2EB", "#CC65FE", "#FFCE56", "#803690",
              "#00ADF9", "#DCDCDC", "#46BFBD", "#FDB45C", "#949FB1",
              "#4D5360", "#80B6F4", "#94D973", "#FAD874", "#F49080"]
    while True:
        for color in colors:
            yield color


@app.route("/auth/login/", methods=['POST'], strict_slashes=False)
def login():
    global config_file
    if request.method == 'POST':
        data = ast.literal_eval(request.data)
        if 'password' in data and os.path.isfile(config_file):
            config = ConfigParser.ConfigParser()
            config.readfp(open(config_file))
            if 'admin' in config.sections():
                current_password = config.get('admin', 'password')
                password = sanitize_user_input(data['password'])
                if obfuscate(password) == current_password:
                    session.clear()
                    session['admin_user'] = True
                    return jsonify({"data": {"response": "Login success!", "authenticated": True}}), 200
                else:
                    return jsonify({"data": {}, "error": "Unauthorised, authentication failure.."}), 401
            else:
                return jsonify({'data': {}, 'error': 'Could not retrieve current credentials..'}), 500
        else:
            return jsonify({"data": {}, "error": "Password needs to be specified"}), 500
    else:
        return jsonify({"data": {}, "error": "Incorrect request method"}), 500


@app.route("/auth/logout/", methods=['GET', 'POST'], strict_slashes=False)
@authenticated
def logout():
    try:
        session.clear()
        return jsonify({"data": {"response": "Logged out successfully!"}}), 200
    except Exception, e:
        logger.error('Error while logging out: %s' % e)
        return jsonify({'data': {}, 'error': 'Exception encountered while logging out..'}), 500


def store_password(password):
    global config_file
    try:
        config = ConfigParser.ConfigParser()
        if os.path.isfile(config_file):
            config.readfp(open(config_file))
            if 'admin' in config.sections():
                config.remove_section('admin')
        config.add_section('admin')
        config.set('admin', 'password', obfuscate(password))

        with open(config_file, 'w') as outfile:
            config.write(outfile)

        return True
    except Exception:
        return False


@app.route("/setup/ganalytics/", methods=['POST'], strict_slashes=False)
@authenticated
def set_ganalytics():
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
        return jsonify({"data": {}, "error": "Incorrect request method"}), 500


def get_ua_id():
    global config_file
    ua_id = ''
    try:
        if os.path.isfile(config_file):
            config = ConfigParser.ConfigParser()
            config.readfp(open(config_file))
            if 'ganalytics' in config.sections():
                ua_id = config.get('ganalytics', 'ua_id')
    except Exception, e:
        logger.error('Error while retrieving UA ID: %s' % e)
    finally:
        return ua_id


def store_ua_id(ua_id):
    global config_file
    try:
        config = ConfigParser.ConfigParser()
        if os.path.isfile(config_file):
            config.readfp(open(config_file))
            if 'ganalytics' in config.sections():
                config.remove_section('ganalytics')
        config.add_section('ganalytics')
        config.set('ganalytics', 'ua_id', ua_id)

        with open(config_file, 'w') as outfile:
            config.write(outfile)

        return True
    except Exception:
        return False


@app.route("/setup/services/", methods=['POST'], strict_slashes=False)
@authenticated
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
        return jsonify({"data": {}, "error": "Incorrect request method"}), 500


def get_services():
    global config_file
    services = []
    try:
        if os.path.isfile(config_file):
            config = ConfigParser.ConfigParser()
            config.readfp(open(config_file))
            if 'services' in config.sections():
                for service in config.items('services'):
                    services.append({'name': service[0], 'url': service[1]})
    except Exception, e:
        logger.error('Error while retrieving services: %s' % e)
    finally:
        return services


def store_services(services):
    global config_file
    try:
        services = ast.literal_eval(services)
        config = ConfigParser.ConfigParser()
        if os.path.isfile(config_file):
            config.readfp(open(config_file))
            if 'services' in config.sections():
                config.remove_section('services')
        config.add_section('services')
        for service in services.get('services', []):
            config.set('services', service.get('name'), '%s:%s' % (service.get('url'), service.get('port')))

        with open(config_file, 'w') as outfile:
            config.write(outfile)

        return True
    except Exception, e:
        logger.error('Error while storing services: %s' % e)
        logger.error('Services: %s' % services)
        return False


@app.route("/setup/config/", methods=['GET'], strict_slashes=False)
@authenticated
def get_config():
    if request.method == 'GET':
        services = get_services()
        ua_id = get_ua_id()
        return jsonify({"data": {"response": "Success!", "services": services, "ua_id": ua_id}}), 200
    else:
        return jsonify({"data": {}, "error": "Incorrect request method"}), 500


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
