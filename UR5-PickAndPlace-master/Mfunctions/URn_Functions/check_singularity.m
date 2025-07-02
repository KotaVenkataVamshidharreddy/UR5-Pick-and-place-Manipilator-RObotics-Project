%% Utility Functions
function is_singular = check_singularity(J, damping_factor)
    % Function to check if the robot is approaching singularity
    % Inputs:
    %   J - Jacobian matrix
    %   damping_factor - Current damping factor
    % Outputs:
    %   is_singular - Boolean indicating if the robot is near singularity

    % Calculate the determinant of the Jacobian matrix
    det_J = det(J);
    
    % Threshold for determinant to consider as near singular
    % If the determinant is close to zero, the matrix is near singular
    threshold = 1e-10;
    if abs(det_J) < threshold
        warning('The robot is approaching a singularity!');
        disp('Jacobian matrix:');
        disp(J);
        is_singular = true;
        % Adjust the damping factor to handle singularity
        new_damping_factor = damping_factor * 10;
        disp(['Increasing damping factor to ', num2str(new_damping_factor)]);
    else
        disp('The robot is in a safe configuration.');
        is_singular = false;
    end
end
