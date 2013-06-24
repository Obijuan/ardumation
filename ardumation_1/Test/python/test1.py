#!/usr/bin/env python
# -*- coding: iso-8859-15 -*-
#----------------------------------------------------------------------------
#  (C)2013 Juan Gonzalez (Obijuan)
#  Released under the GPL license
#----------------------------------------------------------------------------
#
import getopt
import sys
import serial
import time

##-- Write the documentation here
__doc__ = """Testing!!!"""

##-- Default timout for waiting for the robot ack command
DEF_TIMEOUT = 30
ACK_CMD = 'ok\n'

def robot_init():
  """Initial configuration. Read the parameters and initialises the serial port.
     It returns the serial port descriptor
  """
  # parse command line options
  try:
    opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
  except getopt.error, msg:
    print msg
    print "for help use --help"
    sys.exit(2)
    
  # process options
  for o, a in opts:
    if o in ("-h", "--help"):
      print __doc__
      sys.exit(0)

  #-- Default serial ports (if none is given in the arguments)
  serial_name_robot = "/dev/ttyACM0"

  #-- If there are arguments...
  if len(args) > 0:
      
    #-- The first arg. is the robot serial port
    serial_name_robot = args[0]

  print "\n"

  #-- Open the Robot serial port
  try:
    sp_robot = serial.Serial(serial_name_robot, 115200)

  except serial.SerialException:
    sys.stderr.write("Error opening the port {0}".format(serial_name_robot))
    sys.exit(1)

  #--- Set the default serial port timeout
  sp_robot.setTimeout(0.1)

  #-- Port opened
  print "Robot serial port opened: {0}".format(sp_robot.name)

  return sp_robot


def send_cmd(sp, cmd, timeout = DEF_TIMEOUT):
  """Send a g-code cmd to the robot and wait for the answer"""  
  
  #-- Send the cmd
  sp.write(cmd+'\n')
  print "Sending: {}".format(cmd)
  
  #-- Set the timeout
  sp.setTimeout(timeout)
  
  #-- Read the answer
  ok = sp.read(3)
  
  if ok == ACK_CMD:
    print "OK"
  elif ok == "":
    print "TIMEOUT!"
  else:
    print "Received: {}. ERROR".format(ok)
  

#-- Initially the xpos is assumed to be 0
xpos = 0

#-- Larry has two positions insided the tablet and outside
OUT_POS = 7.0
IN_POS = 15.0

#-- X-axis speed (in mm/min)
SPEED = 220.0

#-- Number of cycles (micro-usb in and out) to perform
CYCLES = 20

#-- Waiting time on the inside and outside positions
WAIT = 0.3

def movex_to(s, x):
  """Move the x axis to the x position. It waits until the robot reach that point
     (the time is estimated)
     It returns the estimated time
  """
  global xpos
  
  #-- estimate the time to reach that pos
  t = abs(x - xpos) / (SPEED/60.0);
  
  #-- Send the command
  send_cmd(s, "G1 X{:.1f}".format(x))
  
  #-- Wait until the pos is reached
  time.sleep(t)
  
  #-- updated the current pos
  xpos = x
  
  return t

#------ MAIN -----------------------



#-- Open the serial port (the electronics is reset)
s = robot_init()

#-- Wait some time for the firmware to run
time.sleep(1)

#-- Read all the pending stuff on the buffer (if any)
init_cad = s.readall()
print init_cad

#-- Set absolute coordinates
send_cmd(s, "G90", timeout = 0.2)

#-- Home X axis
send_cmd(s, "G28 X0")

#-- Set speed
send_cmd(s, "G1 F{:.1f}".format(SPEED))

#-- Move to initial pos
movex_to(s, OUT_POS)

#--- Repeat the cycles
for c in range(CYCLES):

  #-- Insert the micro-usb on the tablet
  t1 = movex_to(s, IN_POS)
  
  time.sleep(WAIT)
  
  #-- Move to initial pos
  t2 = movex_to(s,OUT_POS)
  
  time.sleep(WAIT)
  
  print "Cycle time: {:.1f}".format(2*WAIT + t1 + t2)

#-- Move to initial pos
movex_to(s,OUT_POS)

print "Closing serial port.." 
time.sleep(1)

#-- Cerrar puerto serie
s.close()






