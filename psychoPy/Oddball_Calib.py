#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.76.00), Tue 04 Jun 2013 11:10:14 AM EDT
and further modified directly from the created .py file by Petteri Teikari, 2013
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, gui, sound
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
from datetime import datetime # for timing  if needed

# from psychopy.iohub import launchHubServer # import ioHub for button monitoring
# see http://www.isolver-solutions.com/iohubdocs/iohub/quickstart.html
# problems configuring ioHub, so uncomment at some point from gevent works properly

# create the process that will ru n in the background polling devices
# io=launchHubServer()

# some default devices have been created that can now be used
# display = io.devices.display
# keyboard = io.devices.keyboard
# mouse=io.devices.mouse

import u6 # Import LabJack U6 USB Daq

#initalize LabJack U6
d  = u6.U6(debug = False) # add try/catch here
print d.configU6()

# Configure the LabJack U6
print d.configIO()

# DEFINE THE REGISTERS
# FI00 and FI01 for USER BUTTON Presses
# FI02 and FI03 for TRIGGERS (Standard and Deviant)
# http://labjack.com/support/modbus/ud-modbus
'''
FIO0_DIR_REGISTER = 6100
FIO0_STATE_REGISTER = 6000
FIO1_DIR_REGISTER = 6101
FIO1_STATE_REGISTER = 6001
FIO2_DIR_REGISTER = 6102
FIO2_STATE_REGISTER = 6002
FIO3_DIR_REGISTER = 6103
FIO3_STATE_REGISTER = 6003
'''

# SET THE REGISTER DIRECTIONS
# http://labjack.com/support/labjackpython
'''
d.writeRegister(FIO0_DIR_REGISTER, 0) # input
d.writeRegister(FIO1_DIR_REGISTER, 0) # input
d.writeRegister(FIO2_DIR_REGISTER, 1) # output
d.writeRegister(FIO3_DIR_REGISTER, 1) # output
'''

# set all registers to LOW at INITIALIZATION
'''
d.writeRegister(FIO0_STATE_REGISTER, 0) # input
d.writeRegister(FIO1_STATE_REGISTER, 0) # input
d.writeRegister(FIO2_STATE_REGISTER, 0) # output
d.writeRegister(FIO3_STATE_REGISTER, 0) # output
'''
# Init button values
d.getFeedback(u6.BitStateWrite( 0, 0 ), u6.BitStateWrite( 1, 0 ) )
d.getFeedback(u6.BitDirWrite( 0, 0 ), u6.BitDirWrite( 1, 0 ) )

# Store info about the experiment session
expName = 'Oddball_initial'  # from the Builder filename that created this script
expInfo = {u'session': u'001', u'participant': u''}
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
soundDuration = 0.2 # the duration of each stimulus

# Setup files for saving
if not os.path.isdir('data'):
    os.makedirs('data')  # if this fails (e.g. permissions) we will get error
filename = 'data' + os.path.sep + '%s_%s' %(expInfo['participant'], expInfo['date'])
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True, saveWideText=True,
    dataFileName=filename)

# Setup the Window
win = visual.Window(size=(280, 150), fullscr=False, screen=0, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[-1.000,-1.000,-1.000], colorSpace='rgb')

# Initialize components for Routine "trial"
trialClock = core.Clock()
LearningOddballParadigm = sound.Sound('A', secs=soundDuration)
LearningOddballParadigm.setVolume(1)

# Initialize components for Routine "trial"
# trialClock = core.Clock()
# LearningOddballParadigm = sound.Sound('A', secs=0.8)
# LearningOddballParadigm.setVolume(1)
# WHY TWICE FROM BUILDER? (Petteri)

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

# Define the Cycle loop for LEARNING ODDBALL paradigm
# e.g. Jongsma et al. (2013), http://dx.doi.org/10.1016/j.clinph.2012.09.009 (Fig. 1)
# i.e. there are 6 cycles (or blocks) of 16 consecutive targets, so that the 
# first 8 targets of each cycle are presented at random position (irregularTargets, see below)
# preceded by a semi-random 2-6 or 8-12 number of standard tones,
# and the last 8 targets are presented at fixed position always preceded by 7 standard tones
# (regularTargets see below), the subjects task is to press a button after the first standard 
# tone following the oddball ('delayed response task')

CycleLoop = data.TrialHandler(nReps=1, method=u'sequential', 
    extraInfo=expInfo, originPath=None,
    trialList=[None],
    seed=None, name='CycleLoop')
thisExp.addLoop(CycleLoop)  # add the loop to the experiment
thisCycleLoop = CycleLoop.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisCycleLoop.rgb)
if thisCycleLoop != None:
    for paramName in thisCycleLoop.keys():
        exec(paramName + '= thisCycleLoop.' + paramName)

for thisCycleLoop in CycleLoop:
    currentLoop = CycleLoop
    # print "LOOP COUNT (Cycle No): ", currentLoop
    # abbreviate parameter names if possible (e.g. rgb = thisCycleLoop.rgb)
    if thisCycleLoop != None:
        for paramName in thisCycleLoop.keys():
            exec(paramName + '= thisCycleLoop.' + paramName)
    
    # LOOP for IRREGULAR TARGETS
    irregularTargets = data.TrialHandler(nReps=4, method=u'random', 
        extraInfo=expInfo, originPath=None,
        trialList=data.importConditions('Oddballs_irregular_WavFilesCalib.csv'),
        seed=None, name='irregularTargets')
        # NOTE now how there are only 4 repetitions (nReps) of the irregularTargets,
        # whereas you might assume 8 to be the correct number, but now as we define
        # the deviant-deviant interval differently so that the deviant can be preceded by
        # 2-6 or 8-12 standard tones and during 8 consecutive tones there might be two deviants
        # for example the each block now consists of 16 tones in contrast to 8 tones per block
        # of the regular condition (see below), see the Fig. 1 of Jongsma et al. (2013) for graphical
        # representation

    thisExp.addLoop(irregularTargets)  # add the loop to the experiment
    thisIrregularTarget = irregularTargets.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisIrregularTarget.rgb)
    if thisIrregularTarget != None:
        for paramName in thisIrregularTarget.keys():
            exec(paramName + '= thisIrregularTarget.' + paramName)
    
    for thisIrregularTarget in irregularTargets:
        currentLoop = irregularTargets
        # abbreviate parameter names if possible (e.g. rgb = thisIrregularTarget.rgb)
        if thisIrregularTarget != None:
            for paramName in thisIrregularTarget.keys():
                exec(paramName + '= thisIrregularTarget.' + paramName)
        
        #------Prepare to start Routine "trial"-------
        t = 0
        trialClock.reset()  # clock 
        frameN = -1
        timeNow= datetime.now()
        # update component parameters for each repeat

        Sounds = os.path.join(Subfolder, Filename) # so that relative path works both in Linux/Mac and Win
        # https://groups.google.com/forum/?fromgroups#!topic/psychopy-users/twtPKicPGeQ
        LearningOddballParadigm.setSound(Sounds)
        
        if oddBallYes== 1:
            # what to do when oddball is presented, i.e. send a digital output as a trigger to the EEG system
            # print "   Irregular oddball, time:", timeNow
            # see, e.g. http://labjack.com//support/labjackpython
            d.getFeedback(u6.BitStateWrite( 3, 1 ), u6.BitStateWrite( 2, 0 ) )
            buttons = d.getFeedback(u6.BitStateRead( 0 ), u6.BitStateRead( 1 ) )
            directions  = d.getFeedback(u6.BitDirRead( 0 ), u6.BitDirRead( 1 ) )
            ainValue = d.getAIN(0)  # Read from AIN0 in one function    
            # print "      button 1 (FI00): ", buttons[0], "        direction: ", directions[0]
            # print ",     button 2 (FI01): ", buttons[1], "        direction: ", directions[1]
            # print "      AIN00: ", "%1.2f" % ainValue, " V"
        elif oddBallYes==0:
            # what to do when standard tone is presented, i.e. other digital output line trigger to EEG
            print "   Irregular standard tone, time:", timeNow
            d.getFeedback(u6.BitStateWrite( 3, 0 ), u6.BitStateWrite( 2, 1 ) )
            buttons = d.getFeedback(u6.BitStateRead( 0 ), u6.BitStateRead( 1 ) )
            directions  = d.getFeedback(u6.BitDirRead( 0 ), u6.BitDirRead( 1 ) )
            ainValue = d.getAIN(0)  # Read from AIN0 in one function    
            # print "      button 1 (FI00): ", buttons[0], "        direction: ", directions[0]
            # print ",     button 2 (FI01): ", buttons[1], "        direction: ", directions[1] 
            # print "      AIN00: ", "%1.2f" % ainValue, " V"
        else:
            print "   Definition of sound incorrect for irregular targets!"
        # keep track of which components have finished
        trialComponents = []
        trialComponents.append(LearningOddballParadigm)
        for thisComponent in trialComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "trial"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = trialClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # start/stop LearningOddballParadigm
            if frameN >= 0 and LearningOddballParadigm.status == NOT_STARTED:
                # keep track of start time/frame for later
                LearningOddballParadigm.tStart = t  # underestimates by a little under one frame
                LearningOddballParadigm.frameNStart = frameN  # exact frame index
                LearningOddballParadigm.play()  # start the sound (it finishes automatically)
            elif LearningOddballParadigm.status == STARTED and t >= (LearningOddballParadigm.tStart + soundDuration):
                # Why 0.2 is fixed? (PT)
                LearningOddballParadigm.stop()  # stop the sound (if longer than duration)
            
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested that we end
                routineTimer.reset()  # this is the new t0 for non-slip Routines
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in trialComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the [Esc] key)
            if event.getKeys(["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "trial"-------
        for thisComponent in trialComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        thisExp.nextEntry()
        
    # completed all the repeats of 'irregularTargets'
    
    # get names of stimulus parameters
    if irregularTargets.trialList in ([], [None], None):  params = []
    else:  params = irregularTargets.trialList[0].keys()
    # save data for this loop
    irregularTargets.saveAsExcel(filename + '.xlsx', sheetName='irregularTargets',
        stimOut=params,
        dataOut=['n','all_mean','all_std', 'all_raw'])
    
    # LOOP for REGULAR TARGETS
    regularTargets = data.TrialHandler(nReps=8, method=u'sequential', 
        extraInfo=expInfo, originPath=None,
        trialList=data.importConditions(u'Oddballs_regular_WavFiles.csv'),
        seed=None, name='regularTargets')
    thisExp.addLoop(regularTargets)  # add the loop to the experiment
    thisRegularTarget = regularTargets.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisRegularTarget.rgb)
    if thisRegularTarget != None:
        for paramName in thisRegularTarget.keys():
            exec(paramName + '= thisRegularTarget.' + paramName)
    
    for thisRegularTarget in regularTargets:
        currentLoop = regularTargets
        # abbreviate parameter names if possible (e.g. rgb = thisRegularTarget.rgb)
        if thisRegularTarget != None:
            for paramName in thisRegularTarget.keys():
                exec(paramName + '= thisRegularTarget.' + paramName)
        
        #------Prepare to start Routine "trial"-------
        t = 0
        trialClock.reset()  # clock 
        frameN = -1
        timeNow= datetime.now()
        # update component parameters for each repeat

        Sounds = os.path.join(Subfolder, Filename) # so that relative path works both in Linux/Mac and Win
        # Check e.g. https://groups.google.com/forum/?fromgroups#!topic/psychopy-users/twtPKicPGeQ
        LearningOddballParadigm.setSound(Sounds)
        
        if oddBallYes== 1: # put this inside a function later maybe?
            # check also if the values can be written at once to ports rather than to pins?
            # what to do when oddball is presented, i.e. send a digital output as a trigger to the EEG system
            # print "Irregular oddball, time:", timeNow
            # see, e.g. http://labjack.com//support/labjackpython
            d.getFeedback(u6.BitStateWrite( 3, 1 ), u6.BitStateWrite( 2, 0 ) )
            buttons = d.getFeedback(u6.BitStateRead( 0 ), u6.BitStateRead( 1 ) )
            directions  = d.getFeedback(u6.BitDirRead( 0 ), u6.BitDirRead( 1 ) )
            ainValue = d.getAIN(0)  # Read from AIN0 in one function    
            # print "      button 1 (FI00): ", buttons[0], "        direction: ", directions[0]
            # print ",     button 2 (FI01): ", buttons[1], "        direction: ", directions[1]
            # print "      AIN00: ", "%1.2f" % ainValue, " V"
        elif oddBallYes==0:
            # what to do when standard tone is presented, i.e. other digital output line trigger to EEG
            # print "   Irregular standard tone, time:", timeNow
            d.getFeedback(u6.BitStateWrite( 3, 0 ), u6.BitStateWrite( 2, 1 ) )
            buttons = d.getFeedback(u6.BitStateRead( 0 ), u6.BitStateRead( 1 ) )
            directions  = d.getFeedback(u6.BitDirRead( 0 ), u6.BitDirRead( 1 ) )
            ainValue = d.getAIN(0)  # Read from AIN0 in one function    
            # print "      button 1 (FI00): ", buttons[0], "        direction: ", directions[0]
            # print ",     button 2 (FI01): ", buttons[1], "        direction: ", directions[1] 
            # print "      AIN00: ", "%1.2f" % ainValue, " V"
        else:
            print "Definition of sound incorrect for irregular targets!"            
        # keep track of which components have finished
        trialComponents = []
        trialComponents.append(LearningOddballParadigm)
        for thisComponent in trialComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "trial"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = trialClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # start/stop LearningOddballParadigm
            if frameN >= 0 and LearningOddballParadigm.status == NOT_STARTED:
                # keep track of start time/frame for later
                LearningOddballParadigm.tStart = t  # underestimates by a little under one frame
                LearningOddballParadigm.frameNStart = frameN  # exact frame index
                LearningOddballParadigm.play()  # start the sound (it finishes automatically)
            elif LearningOddballParadigm.status == STARTED and t >= (LearningOddballParadigm.tStart + soundDuration):
                LearningOddballParadigm.stop()  # stop the sound (if longer than duration)
            
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested that we end
                routineTimer.reset()  # this is the new t0 for non-slip Routines
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in trialComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the [Esc] key)
            if event.getKeys(["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "trial"-------
        for thisComponent in trialComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        thisExp.nextEntry()
        
    # completed 8 repeats of 'regularTargets'
    
    # get names of stimulus parameters
    if regularTargets.trialList in ([], [None], None):  params = []
    else:  params = regularTargets.trialList[0].keys()
    # save data for this loop
    regularTargets.saveAsExcel(filename + '.xlsx', sheetName='regularTargets',
        stimOut=params,
        dataOut=['n','all_mean','all_std', 'all_raw'])
    thisExp.nextEntry()
    
# completed 6 repeats of 'CycleLoop'

# get names of stimulus parameters
if CycleLoop.trialList in ([], [None], None):  params = []
else:  params = CycleLoop.trialList[0].keys()
# save data for this loop
CycleLoop.saveAsExcel(filename + '.xlsx', sheetName='CycleLoop',
    stimOut=params,
    dataOut=['n','all_mean','all_std', 'all_raw'])

d.getFeedback(u6.BitStateWrite( 3, 0 ) ) # FI03 (3), set LOW (0), i.e. trigger for ODDBALL 
d.getFeedback(u6.BitStateWrite( 2, 0 ) ) # FI02 (2), set LOW (0), i.e. trigger for STANDARD TONE
d.getFeedback(u6.BitStateWrite( 0, 0 ) ) # FI00 (0), set LOW (0), i.e. debug LED
d.close() # Close the device
win.close()
core.quit()
