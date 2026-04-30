import os
import os
import json
import time
import random
import threading
import paho.mqtt.client as mqtt
import os
import logging
from datetime import datetime
from time import sleep
import csv

import paramiko
import sys


cmd = "scp ./data.csv root@166.111.238.97:/home/uisrc/data.csv"


os.system(cmd)

ts_str = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
cmd = "cp ./data.csv ./data_gen_"+ts_str+".csv"
os.system(cmd)