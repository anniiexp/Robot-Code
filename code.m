% Start moving motors forward
brick.MoveMotor('A', 40);
brick.MoveMotor('D', 40);

% Safe distance for wall avoidance
safeDistance = 5.08;

% Continuous loop to check both the touch and ultrasonic sensors
while true
    % Check if the touch sensor is pressed
    touch = brick.TouchPressed(1);
    stopProgram = brick.TouchPressed(4);

    if stopProgram
        brick.StopAllMotors();
        break;
    end

    if touch
        % If touch sensor is pressed, stop and turn
        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');

        brick.MoveMotor('A', -30);
        brick.MoveMotor('D', -30);

        pause(1);

        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');

        
        % Turn by moving motor A backward slightly
        brick.MoveMotorAngleRel('A', -30, -380, 'Brake');
        brick.WaitForMotor('A');
        
        % Moves robot again
        brick.MoveMotor('A', 30);
        brick.MoveMotor('D', 30);
    end
    
    % WALL AVOIDANCE 
    distance = brick.UltrasonicDist(3);
    
    if distance < safeDistance
        % Stop and adjust if too close to the wall
        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');
        
        % Make a small turn to move away from the wall
        brick.MoveMotorAngleRel('A', 20, 100, 'Brake');
        brick.MoveMotorAngleRel('D', -20, 100, 'Brake');
        
        % Wait for the turn to complete
        brick.WaitForMotor('A');
        brick.WaitForMotor('D');
        
        % Resume forward movement
        brick.MoveMotor('A', 20);
        brick.MoveMotor('D', 20);
    end

    % CHECKS FOR RED = STOP
    brick.SetColorMode(2, 2);
    currentColor = brick.ColorCode(2);
    
    % 5 is red
    if currentColor == 5 
        % stops robot when red is detected
        brick.StopAllMotors('Brake');
        pause(1);

        % resumes movement
        brick.MoveMotor('A', 30);
        brick.MoveMotor('D', 30);
    end

    % Checks for blue
    if currentColor == 2
        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');

        brick.MoveMotorAngleRel('B', 30, 550, 'Brake');  % Adjust the angle (90) as needed for full opening
        brick.WaitForMotor('B');  % Wait until the claw is fully open

        pause(2);  % Wait for 2 seconds to pick up the person
        brick.MoveMotor('A', -12);
        brick.MoveMotor('D', -12);

        pause(1); % Move forward for 1 second

        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');


        % Close the claw
        brick.MoveMotorAngleRel('B', -30, 550, 'Brake');  % Adjust the angle (90) as needed for full closure
        brick.WaitForMotor('B');  % Wait until the claw is fully closed
    end
end