# Perform flux and bandpass calibration for the phase calibrator (mm observations only)


FREQ=33000          #Frequency to perform calibration on

# Perform initial bandpass calibration, and flag
mfcal vis=$BANDPASS_CAL.$FREQ interval=0.1

pgflag vis=$BANDPASS_CAL.$FREQ stokes=xx,yy device=/xs command=\<b
pgflag vis=$BANDPASS_CAL.$FREQ stokes=yy,xx device=/xs command=\<b

blflag vis=$BANDPASS_CAL.$FREQ stokes=xx,yy axis=chan,amp options=nofqav,nobase device=/xs

mfcal vis=$BANDPASS_CAL.$FREQ interval=0.1


# Perform gain and polarisation calibration on the phase calibrator, flag, calibrate gains
gpcopy vis=$BANDPASS_CAL.$FREQ out=$PHASE_CAL.$FREQ
gpcal vis=$PHASE_CAL.$FREQ interval=0.1 options=xyvary,qusolve nfbin=$NFBIN

pgflag vis=$PHASE_CAL.$FREQ stokes=xx,yy device=/xs command=\<b
pgflag vis=$PHASE_CAL.$FREQ stokes=yy,xx device=/xs command=\<b

blflag vis=$PHASE_CAL.$FREQ stokes=xx,yy axis=chan,amp options=nofqav,nobase device=/xs
blflag vis=$PHASE_CAL.$FREQ stokes=xx,yy axis=chan,phase options=nofqav,nobase device=/xs

gpcal vis=$PHASE_CAL.$FREQ interval=0.1 options=xyvary,qusolve nfbin=$NFBIN


# Copy gain and polarisation to the primary flux calibrator, flag, calibrate flux scale
gpcopy vis=$PHASE_CAL.$FREQ out=$FLUX_CAL.$FREQ

pgflag vis=$FLUX_CAL.$FREQ stokes=xx,yy device=/xs command=\<b
pgflag vis=$FLUX_CAL.$FREQ stokes=yy,xx device=/xs command=\<b
blflag vis=$FLUX_CAL.$FREQ stokes=xx,yy axis=chan,amp options=nofqav,nobase device=/xs

gpcal vis=$FLUX_CAL.$FREQ interval=0.1 options=xyvary,qusolve,nopol nfbin=$NFBIN


# Copy flux calibration solution to the phase calibrator
gpboot vis=$PHASE_CAL.$FREQ cal=$FLUX_CAL.$FREQ



# Copy gain solutions to bandpass calibrator, recalibrate, bootstrap the flux scale
gpcopy vis=$PHASE_CAL.$FREQ out=$BANDPASS_CAL.$FREQ
gpcal vis=$BANDPASS_CAL.$FREQ interval=0.1 nfbin=$NFBIN
gpboot vis=$BANDPASS_CAL.$FREQ cal=$PHASE_CAL.$FREQ

############
#
# We can now improve the bandpass solution by using both bands
# To do this, run the above code for both frequency bands
#
############

# Fit the SED of the bandpass with uvfmeas, and manually copy the output to $MFCALMEAS
uvfmeas vis=$BANDPASS_CAL.33000,$BANDPASS_CAL.35000 stokes=i order=1 options=plotvec,log,mfflux device=/xs
MFCALMEAS= #Note: this should be 3 numbers separated by commas, with **no spaces**


############
#
# Now run the below commands for both bands
#
############


# Re-do the calibration using the improved flux scale of the bandpass calibrator
mfcal vis=$BANDPASS_CAL.$FREQ interval=0.1 flux=$MFCALMEAS

gpcopy vis=$BANDPASS_CAL.$FREQ out=$PHASE_CAL.$FREQ
gpcal vis=$PHASE_CAL.$FREQ interval=0.1 nfbin=$NFBIN options=xyvary,qusolve
gpcopy vis=$PHASE_CAL.$FREQ out=$BANDPASS_CAL.$FREQ
gpcal vis=$BANDPASS_CAL.$FREQ interval=0.1 nfbin=$NFBIN options=xyvary,qusolve,nopol

gpboot vis=$PHASE_CAL.$FREQ cal=$BANDPASS_CAL.$FREQ
mfboot vis=$PHASE_CAL.$FREQ,$BANDPASS_CAL.$FREQ select=source\($BANDPASS_CAL\) flux=$MFCALMEAS device=/xs
