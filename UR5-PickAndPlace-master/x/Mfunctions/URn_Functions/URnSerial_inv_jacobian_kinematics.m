function q_dot = URnSerial_inv_jacobian_kinematics(q, v_e)
    % URnSerial_inv_jacobian_kinematics computes joint velocities for a desired end-effector velocity.
    % q is the current joint angles [q1, q2, q3, q4, q5, q6].
    % v_e is the desired end-effector velocity [vx, vy, vz, wx, wy, wz].

    % Compute the Jacobian matrix
    J = URnSerial_jacobian(q)

    % Compute the inverse or pseudo-inverse of the Jacobian matrix
    J_inv = pinv(J);
    
    disp('Inverse Jacobian matrix:');
    disp(J_inv);
    % Compute the joint velocities
    v_e = v_e'; % Transpose v_e if necessary
    q_dot = J_inv * v_e;
end
