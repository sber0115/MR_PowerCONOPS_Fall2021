
%when enable_changing_azimuth is enabled, assume starting_azimuth is where the sun starts
%relative to the rover. The sun will clock around at a rate of 13 degrees
%per day.

%when this is enabled, it more or less emulates extremely off-optimal
%roving paths, because ideally we'll always be orienting the panel normal
%to the sun
enable_changing_azimuth = false;
starting_azimuth = 15;


%note, power generation during surface ops is expected to be 68 Watts
%This number is based on the temperature and therefore efficiency of the
%solar cells at those temperatures.
user_power_generation = 55;

%mechanical speed in cm/s
rover_mechanical_speed = 4;