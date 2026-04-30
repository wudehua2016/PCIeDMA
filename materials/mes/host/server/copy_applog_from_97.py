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
cmd = "scp root@166.111.238.97:/home/uisrc/app0000-2000.log ."


os.system(cmd)
ts_str = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
cmd = "cp ./app0000-2000.log ./app0000-2000_"+ts_str+".log"


os.system(cmd)
