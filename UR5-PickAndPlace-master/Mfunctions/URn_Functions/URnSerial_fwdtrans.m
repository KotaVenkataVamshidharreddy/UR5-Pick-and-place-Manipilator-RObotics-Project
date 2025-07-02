function [ G ] = URnSerial_fwdtrans( URnName )
    %% defining the kinematic structure of a robotic arm.
    % Create The Arm Using Peter Corke robotics toolbox

    % Define the parameters based on the robot name
    switch URnName
        case 'UR5'
            a = [0, -0.612, -0.5723, 0, 0, 0];
            d = [0.1273, 0, 0, 0.163941, 0.1157, 0.0922];
            alpha = [1.570796327, 0, 0, 1.570796327, -1.570796327, 0];
        otherwise
            a = [0, -0.612, -0.5723, 0, 0, 0];
            d = [0.1273, 0, 0, 0.163941, 0.1157, 0.0922];
            alpha = [1.570796327, 0, 0, 1.570796327, -1.570796327, 0];   
    end

    offset = [0, -pi/2, 0, -pi/2, 0, 0];

    % Ensure the parameters are correctly defined
    if length(a) ~= 6 || length(d) ~= 6 || length(alpha) ~= 6 || length(offset) ~= 6
        error('Parameter arrays must all be of length 6');
    end

    % Initialize the Link array
    L(6) = Link();  % Preallocate the array with 6 Link objects

    for i = 1:6
        % Create each Link object
        try
            L(i) = Link([0 d(i) a(i) alpha(i) 0 offset(i)], 'standard');
        catch ME
            error('Error creating Link object at index %d: %s', i, ME.message);
        end
    end

    % Create the SerialLink robot
    G = SerialLink(L, 'name', 'URn');

end
