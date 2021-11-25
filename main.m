
is_charging = false;

time_offset = 1;

power_gen_timeline = zeros(1,tv_length);
power_con_timeline = zeros(1,tv_length);

%initialize power variables
power_generation = nom_power_generation;
power_consumption = 0;

%this is what's added to total_distance_traveled every iteration
distance_traveled = 0;

%iterate over the operating mode power vector to get the
%%power consumption associated with a specific time frame
for i = 1:length(op_times)
    power_consumption = op_modes(i);
      
    %the power over that time frame remains constant, so iterate
    %over the task duration vector, for a duration = entry in vector 
    %i.e op_times(1) = time duration for the first idling period in the mission
    for j = 1:op_times(i)
        
        if (time_offset > 1)
            %62 corresponds to the index in the task vector that
            %corresponds to shadow operations (occultation period)
            if (i == 62)
                power_generation = 20;
                power_consumption = op_modes(i);
                distance_traveled = 0;

            elseif (is_charging && battery_cap(time_offset-1) > end_charge_soc*battery_total)
                is_charging = false;
                %make sure power_generation is consistent with user input
                %if they disabled changing azimuth
                if (enable_changing_azimuth)
                    power_generation = nom_power_generation*angle_offset(time_offset);
                else 
                    power_generation = nom_power_generation;
                end
                power_consumption = op_modes(i);
                distance_traveled = velocity_in_meters;
                
            elseif (is_charging)
                power_generation = nom_power_generation;
                power_consumption = 45;
                distance_traveled = 0;
               
            elseif (battery_cap(time_offset-1) < start_charge_soc*battery_total)
                is_charging = true;
                power_generation = nom_power_generation;
                %when sitting to charge, change to idle power consumption
                power_consumption = 45;
                distance_traveled = 0;

            else
                %make sure power_generation is consistent with user input
                %if they disabled changing azimuth
                if (enable_changing_azimuth)
                    power_generation = nom_power_generation*angle_offset(time_offset);
                else 
                    power_generation = nom_power_generation;
                end
       
                power_consumption = op_modes(i);
                distance_traveled = velocity_in_meters;
            end

            energy_change =  power_generation - power_consumption;
            %total_distance_traveled = total_distance_traveled + distance_traveled;

            temp_cap = battery_cap(time_offset-1) + energy_change;

            if (abs(temp_cap/battery_total - 1) > tolerance)
                battery_cap(time_offset) = (battery_cap(time_offset-1) + energy_change);
            else
                battery_cap(time_offset) = battery_cap(time_offset-1);
            end
            
        end
        
        power_gen_timeline(time_offset) = power_generation;
        power_con_timeline(time_offset) = power_consumption;
        
        time_offset = time_offset+1;
        total_distance_traveled = total_distance_traveled + distance_traveled;
        movement_duration = movement_duration+1;
       
    end
end

speed_made_good_in_meters = 100*(total_distance_traveled / movement_duration)
    