import datetime

from sqlalchemy import (BigInteger, Column, DateTime, ForeignKey, Integer,
                        String)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()


class Server(Base):
    ''' Server running the probe '''
    __tablename__ = 'server'
    id = Column(Integer, primary_key=True)
    hostname = Column(String(250), nullable=False)


class Version(Base):
    __tablename__ = 'version'
    id = Column(Integer, primary_key=True)
    date_time = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)
    timestamp = Column(BigInteger)
    version = Column(String(128))
    full_version = Column(String(2048))
    server_id = Column(Integer, ForeignKey('server.id'))
    server = relationship(Server)


class Service(Base):
    __tablename__ = 'service'
    id = Column(Integer, primary_key=True)
    name = Column(String(128))
    uri = Column(String(1024))
    server_id = Column(Integer, ForeignKey('server.id'))
    server = relationship(Server)


class Metrics(Base):
    __tablename__ = 'metrics'
    id = Column(Integer, primary_key=True)
    date_time = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)
    timestamp = Column(BigInteger)
    latency = Column(Integer)
    available = Column(Integer)
    service_name = Column(String(128))
