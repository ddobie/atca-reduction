# Image the target data


# Reasonable cell sizes, if the beam is highly elongated you may want to use something like CELL=0.05,0.5
CELL=1.0    #16cm
CELL=0.3    #5.5 GHz
CELL=0.15   #9 GHz
CELL=0.1    #15mm
CELL=0.05   #7mm lower
CELL=0.03   #7mm upper


# Transform visibility data into a map (optionally, produce a fits file of the map)
rm -rf $FIELD*$FREQ.imap
rm -rf $FIELD*$FREQ.ibeam

invert vis=$FIELD.uvaver.$FREQ map=$FIELD.uvaver.$FREQ.imap beam=$FIELD.uvaver.$FREQ.ibeam robust=0.5 stokes=i cell=$CELL options=mfs,double imsize=347,347
cgdisp in=$FIELD.uvaver.$FREQ.imap type=p labtyp=hms,dms options=wedge device=/xs

fits in=$FIELD.uvaver.$FREQ.imap out=$FIELD.$FREQ.imap.fits op=xyout


# Run the clean algorithm to produce a model image
CLEANTHRESH= #Set a clean threshold (a rough guide is 5-10 times the theoretical noise estimate produced by invert)
NITERS= #Set the maximum number of issues

rm -rf $FIELD*$FREQ.imodel

clean map=$FIELD.uvaver.$FREQ.imap beam=$FIELD.uvaver.$FREQ.ibeam out=$FIELD.uvaver.$FREQ.imodel niters=$NITERS cutoff=$CLEANTHRESH options=negstop,positive


# Convolve the clean model with the beam  to produce the clean map
rm -rf $FIELD*$FREQ.irestor
rm $FIELD.$FREQ.fits

restor model=$FIELD.uvaver.$FREQ.imodel beam=$FIELD.uvaver.$FREQ.ibeam map=$FIELD.uvaver.$FREQ.imap out=$FIELD.uvaver.$FREQ.irestor
cgdisp in=$FIELD.uvaver.$FREQ.irestor type=p labtyp=hms,dms options=wedge device=/xs range=0,0,log
fits in=$FIELD.uvaver.$FREQ.irestor out=$FIELD.$FREQ.fits op=xyout


# Fit a point source at the image centre, store the fit information and produce a residual image
rm -rf $FIELD*$FREQ.iresidual*

imfit in=$FIELD.uvaver.$FREQ.irestor object=point spar=1,0,0 out=$FIELD.$FREQ.iresidual options=residual > $FIELD.$FREQ.INFO.dat region=relcenter,box\(-10,-10,10,10\)

fits in=$FIELD.$FREQ.iresidual out=$FIELD.$FREQ.iresidual.fits op=xyout
