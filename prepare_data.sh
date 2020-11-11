# Initial preparation of the data
# Defines variables, performs initial flagging and produces indivudal uv files for each source/frequency


PROJECT=            #ATCA project code
FLUX_CAL=1934-638
BANDPASS_CAL=       #Should be 1934-638 for 4cm/16cm bands, or a dedicated bandpass calibrator otherwise
PHASE_CAL=          #Phase calibrator source name
FIELD=              #Target source name
TIME_ON_PHASE=      #Time spent on phase calibrator in minutes
NFBIN=4             #Number of frequency bins

# Convert the raw data to uvfits. Load all files.
atlod in="$DAY*.$PROJECT" out=$PROJECT.uv options="birdie,xycorr,rfiflag,opcorr,noauto"


rm -rf *.uv
uvflag vis=$PROJECT.uv edge=40 flagval=flag #change this if using different correlator config, e.g. set edge=1 if using the continuum band of a zoom mode

rm -rf $FLUX_CAL.*
rm -rf $BANDPASS_CAL.*
rm -rf $PHASE_CAL.*
rm -rf $FIELD.*
# Split into one UV file per source.
uvsplit vis=$PROJECT.uv

# If using a hybrid correlator config use someting like this
uvflag vis=*.33000.1 edge=40 flagval=flag
uvflag vis=*.35000.2 edge=1 flagval=flag
