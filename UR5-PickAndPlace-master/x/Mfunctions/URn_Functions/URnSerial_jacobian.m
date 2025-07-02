function J = URnSerial_jacobian(q)
    % URnSerial_jacobian calculates the Jacobian matrix for the UR5 robot.
    % q is a vector of joint angles [q1, q2, q3, q4, q5, q6].

    % DH parameters for UR5
    a = [0, -0.612, -0.5723, 0, 0, 0];
    d = [0.1273, 0, 0, 0.163941, 0.1157, 0.0922];
    alpha = [1.570796327, 0, 0, 1.570796327, -1.570796327, 0];
    theta = q;  % Joint angles

    % Initialize transformation matrix and Jacobian matrix
    T = eye(4);
    J = zeros(6, 6);
    z = [0; 0; 1];
    p = [0; 0; 0];

    % Compute transformation matrices and Jacobian columns
    for i = 1:6
        % Compute the transformation matrix for the current link
        T = T * DH_to_transform(theta(i), d(i), a(i), alpha(i));
        z = T(1:3, 3); % Z axis
        p = T(1:3, 4); % Position

        % Compute the Jacobian columns
        J(1:3, i) = cross(z, (p - T(1:3, 4)));
        J(4:6, i) = z;
    end
end

function T = DH_to_transform(theta, d, a, alpha)
    % DH_to_transform computes the transformation matrix from DH parameters.
    T = [cos(theta), -sin(theta)*cos(alpha), sin(theta)*sin(alpha), a*cos(theta);
         sin(theta), cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
         0, sin(alpha), cos(alpha), d;
         0, 0, 0, 1];
end
