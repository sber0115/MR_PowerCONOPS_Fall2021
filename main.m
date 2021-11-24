
time_offset = 1;

power_gen_timeline = zeros(1,tv_length);
power_con_timeline = zeros(1,tv_length);

%change the loop guard so it iterates over every time period
for i = 1:length(op_times)
    power_consumption = op_modes(i);
    
    for j = 1:op_times(i)

        energy_change = nom_power_generation*angle_offset(time_offset) ...
                        - power_consumption;
                    
        power_gen_timeline(time_offset) = nom_power_generation*angle_offset(time_offset);
        power_con_timeline(time_offset) = power_consumption;
        
        if (time_offset > 1)
            temp_cap = battery_cap(time_offset-1) + energy_change;
            
            

            if (abs(temp_cap/battery_total - 1) > tolerance)
                battery_cap(time_offset) = (battery_cap(time_offset-1) + energy_change);
            else
                battery_cap(time_offset) = battery_cap(time_offset-1);
            end
        end
       
        time_offset = time_offset+1;
       
    end
end
    