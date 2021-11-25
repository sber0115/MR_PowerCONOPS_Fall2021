nom_power_generation = user_power_generation;

%start treks with this state of charge (post-deployment)
init_soc = 0.8;

%if soc falls below this percentage, then stop moving, orient yourself, and
%starting charging
start_charge_soc = 0.5;

%if soc after starting to charge reaches this, then continue roving
end_charge_soc = 0.9;

%used to check if battery state of charge exceeds 100%, or reaches 0%
tolerance  = 1e-2; 

%setting up excel file readings
timeline_filename = 'Power consumption timeline.xlsx';
op_mode_power_range = 'D2:D188';
task_duration_range = 'E2:E188';
sheet_name = 'Y23 Timeline - Rev 2';

%the time vector is used as the x-axis when plotting
tv_length = xlsread(timeline_filename, sheet_name, 'G3');
%mins to secs
tv_length = tv_length*60;
time_vector = 1:tv_length;

%azimuth angle values are in degrees
azimuth_angle = zeros(1, tv_length); 
azimuth_angle(1) = starting_azimuth; 

angle_offset = zeros(1, tv_length);
battery_cap = zeros(1,tv_length);

%use this to add up distances travel, and then divide by time it took to
%travel this distance to get speed-made-good
total_distance_traveled = 0;

%will get incremented whenever in teleop or auto operating mode
movement_duration = 0;

%maximum battery energy capacity in Joules
battery_total = 200*3600; 
velocity_in_cm  = rover_mechanical_speed;
velocity_in_meters = velocity_in_cm/100;

for i = 2:tv_length
    prev_value = azimuth_angle(i-1);
    %sun clocks 13 degrees per day, convert to rate in degrees per second
    diff = 13 / (24*60^2); 
    azimuth_angle(i) = prev_value + diff;
end

if (~enable_changing_azimuth)
    azimuth_angle(1:tv_length) = 90;
end

%elevation_angle = normrnd(5,5,[1,tv_length]);
elevation_angle = 5;

%middle coordinate is sqrt(panel height*(half the panel width))
panel_normal_vector = [0, 203.125, 0];

for i = 1: tv_length
    azimuth_to_use = azimuth_angle(i);
    %elevation_to_use = elevation_angle(i);
    elevation_to_use = elevation_angle;
    %note that the magnitude passed into sph2cart is 1353, which is the
    %irradiance assumed to fall on the solar panel (1353 W/m^2)
    [s1, s2, s3] = sph2cart(deg2rad(azimuth_to_use),deg2rad(elevation_to_use),1353);
    %normalize panel and sun vectors, and get their dot product
    %the result here is multiplied against the 
    angle_offset(i) = dot(panel_normal_vector/norm(panel_normal_vector), [s1,s2,s3]/norm([s1,s2,s3]));
end

soc_under_100 = true;
battery_cap(1) = battery_total*init_soc;

%multiply by 60 to get task durations in seconds
op_times = 60*xlsread(timeline_filename, sheet_name, task_duration_range);
op_modes = xlsread(timeline_filename, sheet_name, op_mode_power_range);

