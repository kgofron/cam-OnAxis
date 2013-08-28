#!/epics/areaDetectorR1-9-1/bin/linux-x86_64/prosilicaApp

### originally, the contents of a generated "envPaths"
epicsEnvSet("ARCH","linux-x86_64")
epicsEnvSet("IOC","iocProsilica")
epicsEnvSet("TOP","/epics/areaDetectorR1-9-1")
epicsEnvSet("SUPPORT","/usr/lib/epics")
epicsEnvSet("ASYN","/usr/lib/epics")
epicsEnvSet("CALC","/usr/lib/epics")
epicsEnvSet("BUSY","/usr/lib/epics")
epicsEnvSet("SSCAN","/usr/lib/epics")
epicsEnvSet("AUTOSAVE","/usr/lib/epics")
epicsEnvSet("AREA_DETECTOR","/epics/areaDetectorR1-9-1")
epicsEnvSet("EPICS_BASE","/usr/lib/epics")

errlogInit(20000)

dbLoadDatabase("$(AREA_DETECTOR)/dbd/prosilicaApp.dbd")

prosilicaApp_registerRecordDeviceDriver(pdbbase) 

epicsEnvSet("PREFIX", "XF:23ID-ES:1{Cam:1}")
epicsEnvSet("PORT",   "PS1")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "2752")
epicsEnvSet("YSIZE",  "2200")
epicsEnvSet("NCHANS", "2048")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "20000000")

# prosilicaConfig(portName,    # The name of the asyn port to be created
#                 cameraId,    # Unique ID, IP address, or IP name of the camera
#                 maxBuffers,  # Maximum number of NDArray buffers driver can allocate. 0=unlimited
#                 maxMemory,   # Maximum memory bytes driver can allocate. 0=unlimited
#                 priority,    # EPICS thread priority for asyn port driver 0=default
#                 stackSize,   # EPICS thread stack size for asyn port driver 0=default
#                 maxPvAPIFrames) # Number of frames to allocate in PvAPI driver. Default=2.
# The simplest way to determine the uniqueId of a camera is to run the Prosilica GigEViewer application, 
# select the camera, and press the "i" icon on the bottom of the main window to show the camera information for this camera. 
# The Unique ID will be displayed on the first line in the information window.
#prosilicaConfig("$(PORT)", 51031, 50, 0, 0, 0, 10)
#prosilicaConfig("$(PORT)", 50022, 50, 0)
prosilicaConfig("$(PORT)", 172.16.1.205, 50, 0)
#prosilicaConfig("$(PORT)", 51039, 50, 0)

asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,255)

dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/ADBase.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
# Note that prosilica.template must be loaded after NDFile.template to replace the file format correctly
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/prosilica.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

#prosilicaConfig("PS2", 50022, 10, 50000000)
#dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/ADBase.template",   "P=$(PREFIX),R=cam2:,PORT=PS2,ADDR=0,TIMEOUT=1")
#dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/prosilica.template","P=$(PREFIX),R=cam2:,PORT=PS2,ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from first Prosilica driver.
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0")

# Use this line if you only want to use the Prosilica in 8-bit mode.  It uses an 8-bit waveform record
# NELEMENTS is set large enough for a 1360x1024x3 image size, which is the number of pixels in RGB images from the GC1380CH color camera. 
# Must be at least as big as the maximum size of your camera images
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,TYPE=Int8,FTVL=UCHAR,NELEMENTS=18163200")

# Use this line if you want to use the Prosilica in 8,12 or 16-bit modes.  
# It uses an 16-bit waveform record, so it uses twice the memory and bandwidth required for only 8-bit data.
#dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,TYPE=Int16,FTVL=SHORT,NELEMENTS=4177920")

# Load all other plugins using commonPlugins.cmd
< $(AREA_DETECTOR)/iocBoot/commonPlugins.cmd

#asynSetTraceMask("$(PORT)",0,255)

iocInit()

#asynSetTraceMask("$(PORT)",0,1)

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX),D=cam1:")

