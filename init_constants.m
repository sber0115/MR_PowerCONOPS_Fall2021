nom_power_generation = 68;
init_soc = 0.8;
tolerance  = 1e-2; %used to check if battery state of charge exceeds 100%, or reaches 0%

timeline_filename = 'Power consumption timeline.xlsx';
op_mode_power_range = 'A1:A187';
task_duration_range = 'B1:B187';
sheet_name = 'Y23 Timeline - Rev 2';

tv_length = xlsread(timeline_filename, sheet_name, 'D2');
tv_length = tv_length*60; %mins to secs

time_vector = 1:tv_length;

azimuth_angle = zeros(1, tv_length); %in degrees
azimuth_angle(1) = 15; %starting at 15 degrees azimuth

angle_offset = zeros(1, tv_length);

battery_cap = zeros(1,tv_length);

distance_travelled = zeros(1,tv_length);


battery_total = 200*3600; %maximum battery energy capacity in Joules
velocity_cm  = 4;
velocity_m = velocity_cm/100;
normal_distance = velocity_m;


for i = 2:tv_length
    prev_value = azimuth_angle(i-1);
    diff = 13 / (24*60^2); 
    azimuth_angle(i) = prev_value + diff;
end

%elevation_angle = normrnd(5,5,[1,tv_length]);
elevation_angle = 5;

%middle coordinate is sqrt(panel height*(half the panel width))
panel_normal_vector = [0, 203.125, 0];

for i = 1: tv_length
    azimuth_to_use = azimuth_angle(i);
    %elevation_to_use = elevation_angle(i);
    elevation_to_use = elevation_angle;
    [s1, s2, s3] = sph2cart(deg2rad(azimuth_to_use),deg2rad(elevation_to_use),1353);
    angle_offset(i) = dot(panel_normal_vector/norm(panel_normal_vector), [s1,s2,s3]/norm([s1,s2,s3]));
end

soc_under_100 = true;
battery_cap(1) = battery_total*init_soc;

op_times = 60*xlsread(timeline_filename, sheet_name, task_duration_range);
op_modes = xlsread(timeline_filename, sheet_name, op_mode_power_range);

