arduino = arduino('COM4', 'Uno', 'Libraries', 'Servo');

a = -5;
b = 30;
c = 15;
d = 65;
e = 0;
f = 4;

r1 = [a b c]; % vector: micro servo shaft pos wrt origin (base servo shaft) 
r2 = [d e f]; % vector: arm tip pos wrt origin

normal = [0 1 0]; % initial normal vector to micro servo. rotation caused by Rbase
axang = [n theta2];  % rotation about n by theta2
Rmicro = axang2rotm(axang);

Rbase = [cos(theta1), -sin(theta1), 0;
      sin(theta1),  cos(theta1), 0;
           0,           0,     1];

% 1. increment servo angles theta1, theta2
% 2. update point1, point2 with rotation matrics
% 3. plot in 3D

%rotation about z
%r1 = Rbase * r1
%r2 = Rbase * r2

%micro servo rotation
%calculate Rmicro
%r2 = Rmicro * (p - c) + c





function control_servos()
    % Define the servo objects
    s_base = servo(arduino, 'D9'); % Base servo connected to pin D9
    s_arm = servo(arduino, 'D10'); % Arm servo connected to pin D10

    % Move base servo to 180 degrees
    writePosition(s_base, 1); % 1 corresponds to 180 degrees
    pause(2); % Wait for 2 seconds for the movement to complete

    % Move arm servo to 180 degrees
    writePosition(s_arm, 1); % 1 corresponds to 180 degrees
    pause(2); % Wait for 2 seconds for the movement to complete

    % Return both servos to original positions
    writePosition(s_base, 0); % 0 corresponds to 0 degrees
    writePosition(s_arm, 0); % 0 corresponds to 0 degrees
    pause(2); % Wait for 2 seconds for the movement to complete
end

figure;
axis([-100 100 -100 100 -10 100])
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
hold on;

for k = 1:steps
    % Interpolate angles
    theta1 = deg2rad(theta1_start + (theta1_end - theta1_start) * k/steps);
    theta2 = deg2rad(theta2_start + (theta2_end - theta2_start) * k/steps);

    % Base rotation (about Z axis)
    Rbase = [cos(theta1), -sin(theta1), 0;
             sin(theta1),  cos(theta1), 0;
                  0,            0,      1];

    r1_rot = (Rbase * r1')';

    % Micro servo rotation (rotate around its local axis)
    axis_normal = [0 1 0];
    axang = [axis_normal theta2];
    Rmicro = axang2rotm(axang);

    r2_rel = r2 - r1;  
    r2_rot = (Rbase * (Rmicro * r2_rel')') + r1_rot;

    % Plot arm
    clf;
    plot3([0 r1_rot(1)], [0 r1_rot(2)], [0 r1_rot(3)], 'r-', 'LineWidth', 2);
    hold on;
    plot3([r1_rot(1) r2_rot(1)], [r1_rot(2) r2_rot(2)], [r1_rot(3) r2_rot(3)], 'b-', 'LineWidth', 2);
    scatter3(0,0,0,'ko','filled');
    scatter3(r1_rot(1), r1_rot(2), r1_rot(3),'ro','filled');
    scatter3(r2_rot(1), r2_rot(2), r2_rot(3),'bo','filled');
    xlim([-100 100]); ylim([-100 100]); zlim([-50 100]);
    grid on;
    pause(0.1); % Slow movement
end
