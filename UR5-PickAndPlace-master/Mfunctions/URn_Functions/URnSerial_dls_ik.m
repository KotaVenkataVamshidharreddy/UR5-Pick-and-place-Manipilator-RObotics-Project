function q = URnSerial_dls_ik(T, q0, robot, lambda)
    % T is the target transformation matrix (4x4)
    % q0 is the initial joint configuration (nx1)
    % robot is the robot structure containing DH parameters
    % lambda is the damping factor
    
    % Maximum number of iterations
    max_iter = 1000;
    % Tolerance for convergence
    tol = 1e-6;
    
    % Initialize q with the initial guess
    q = q0;
    
    for i = 1:max_iter
        % Forward kinematics to get current end-effector pose
        T_current = URnSerial_fwdtrans(q, robot);
        
        % Calculate the error in the pose
        delta_T = T - T_current;
        
        % Convert delta_T to a 6x1 error vector
        delta_X = [delta_T(1:3, 4);
                   rotm2eul(delta_T(1:3, 1:3))'];
        
        % Check if the error is within the tolerance
        if norm(delta_X) < tol
            break;
        end
        
        % Compute the Jacobian
        J = URnSerial_jacobian(q, robot);
        
        % Dampened Least Squares Inverse
        JT = J';
        dls_inv = (JT * J + lambda^2 * eye(size(J, 2))) \ JT;
        
        % Update joint configuration
        q = q + dls_inv * delta_X;
    end
end

function eul = rotm2eul(R)
    % Convert rotation matrix to Euler angles (ZYX order)
    sy = sqrt(R(1,1) * R(1,1) +  R(2,1) * R(2,1));
    singular = sy < 1e-6;
    
    if ~singular
        x = atan2(R(3,2), R(3,3));
        y = atan2(-R(3,1), sy);
        z = atan2(R(2,1), R(1,1));
    else
        x = atan2(-R(2,3), R(2,2));
        y = atan2(-R(3,1), sy);
        z = 0;
    end
    
    eul = [z; y; x];
end
