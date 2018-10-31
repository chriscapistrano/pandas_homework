from datetime import date
from datetime import timedelta
from flask import Flask, render_template, jsonify
import numpy as np
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func
from flask import Flask, jsonify
import json


#################################################
# Database Setup
#################################################
engine = create_engine("sqlite:///hawaii.sqlite")

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# Save reference to the table
Measurement = Base.classes.measurement
Stations = Base.classes.station

# Create our session (link) from Python to the DB
session = Session(engine)

app = Flask(__name__)

@app.route('/api/v1.0/precipitation')
def precip():
    # Query "Measurement" table
    results = session.query(Measurement).all()
    # Create a dictionary 
    date_tobs = []
    for i in results:
        info_dict = {}
        info_dict['date'] = i.date
        info_dict['tobs'] = i.tobs
        date_tobs.append(info_dict)
    return jsonify(date_tobs)


@app.route('/api/v1.0/stations')
def stat():
    # Query "Stations" table
    station_results = session.query(Stations).all()
    station_list = []
    for i in station_results:
        stat_dict = {}
        stat_dict['station'] = i.station
        station_list.append(stat_dict)
    return jsonify(station_list)   


@app.route('/api/v1.0/tobs')
def date_tobs():
    dt_tobs_results = session.query(Measurement).filter(Measurement.date >= '2016-08-23').all()
    dt_tobs_list = []
    for i in dt_tobs_results: 
        if i.date > '2016-08-23':
            dt_dict = {}
            dt_dict['date'] = i.date
            dt_dict['tobs'] = i.tobs
            dt_tobs_list.append(dt_dict)
    return jsonify(dt_tobs_list)


@app.route("/api/v1.0/<start>")
def start_date(start):
    results_2 = session.query(Measurement).all()
    start_dt_list = []
    for i in results_2: 
        start_dict = {}
        start_dict['tobs'] = i.tobs
        start_dt_list.append(start_dict)
        search_date = i['date']
        if search_date == start:
            return session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
                filter(Measurement.date >= search_date).all()
 
    return jsonify({"error": f"The date you entered was not found."}), 404   

@app.route("/api/v1.0/<end>")
def end_date(end):
    results_2 = session.query(Measurement).all()
    start_dt_list = []
    for i in results_2: 
        start_dict = {}
        start_dict['tobs'] = i.tobs
        start_dt_list.append(start_dict)
        search_date = i['date']
        if search_date == end:
            return session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
                filter(Measurement.date >= search_date).all()
 
    return jsonify({"error": f"The date you entered was not found."}), 404     

if __name__ == "__main__" :
    app.run(debug=True)
