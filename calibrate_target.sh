# Copy solutions from the phase calibrator to the target, flag, and average

gpcopy vis=$PHASE_CAL.$FREQ out=$FIELD.$FREQ
gpaver vis=$FIELD.$FREQ interval=$TIME_ON_PHASE

pgflag vis=$FIELD.$FREQ stokes=xx,yy device=/xs command=\<b
pgflag vis=$FIELD.$FREQ stokes=yy,xx device=/xs command=\<b

blflag vis=$FIELD.$FREQ stokes=xx,yy axis=chan,amp options=nofqav,nobase device=/xs
blflag vis=$FIELD.$FREQ stokes=xx,yy axis=real,imag options=nofqav,nobase device=/xs

uvaver vis=$FIELD.$FREQ out=$FIELD.uvaver.$FREQ



# If observing at mm wavelengths, you may want to combine both bands rather than treating them separately
uvaver vis=$FIELD.33000,$FIELD.35000 out=$FIELD.uvaver.34000
