wasBlue = false;

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
    
     brick.MoveMotor('A', -50);
     brick.MoveMotor('D', -50);
    
     pause(1);
    
     brick.StopMotor('A', 'Brake');
     brick.StopMotor('D', 'Brake');

        
     % Turn by moving motor A backward slightly
     brick.MoveMotorAngleRel('A', -30, -380, 'Brake');
     brick.WaitForMotor('A');
            
     % Moves robot again
     brick.MoveMotor('A', 50);
     brick.MoveMotor('D', 50);
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

        pause(1);
        
        % turn back straight
        brick.MoveMotorAngleRel('A', -10, 100, 'Brake');
        brick.MoveMotorAngleRel('D', 10, 100, 'Brake');

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
        % Stops robot when red is detected
        brick.StopAllMotors('Brake');
        pause(1);

        % If red is detected for the first time, turn left
        if ~hasTurnedRed
            disp('Red detected for the first time. Turning left...');
            brick.MoveMotorAngleRel('A', -50, 180, 'Brake');  % Turn left
            brick.WaitForMotor('A');  % Wait for the turn to complete
            hasTurnedRed = true;  % Set flag to indicate red turn is completed
        end

        % Resume movement after red detection
        brick.MoveMotor('A', 30);
        brick.MoveMotor('D', 30);
    end

    
    % Checks for blue
    if currentColor == 2 & ~wasBlue
        wasBlue = true;
        brick.StopMotor('A', 'Brake');
        brick.StopMotor('D', 'Brake');

        disp('Blue detected, switching to remote control');
        
        % start remote control
        fig = figure('Name', 'Robot Control', 'KeyPressFcn', @(src, event) keyPress(src, event, brick), ...
             'KeyReleaseFcn', @(src, event) keyRelease(src, event, brick));
        
        disp('Robot control program. Use w (forward), a (left), d (right), s (stop) commands.');
        disp('Use q (open claw) and e (close claw) to control claw');

        waitfor(fig);

        disp('Remote control ended, returning back to autonomous');
    end

    if currentColor ~= 2
        wasBlue = false;
    end
end


% motor remote functions

function keyPress(~, event, brick)
    % detecting which key is pressed
    switch event.Key
        case 'w'
            move_forward(brick);
        case 'a'
            turn_left(brick);
        case 'd'
            turn_right(brick);
        case 's'
            move_backward(brick);
        case 'q'
            open_claw(brick);
        case 'e'
            close_claw(brick);
    end
end


function keyRelease(~, event, brick)
    switch event.Key
        case {'w', 'a', 'd', 's'}
            stop_robot(brick);
        case {'q', 'e'}
            stop_claw(brick);
    end
end


% motor functions

function move_forward(brick)
    brick.MoveMotor('A', -50);
    brick.MoveMotor('D', -50);
end

function turn_left(brick)
    brick.MoveMotor('A', -50);
    brick.StopMotor('D', 'Brake');
end

function turn_right(brick)
    brick.StopMotor('A', 'Brake');
    brick.MoveMotor('D', -50);
end

function move_backward(brick)
    brick.MoveMotor('A', 50);
    brick.MoveMotor('D', 50);
end

function stop_robot(brick)
    brick.StopMotor('A', 'Brake');
    brick.StopMotor('D', 'Brake');
end

% claw functions
function open_claw(brick)
    brick.MoveMotor('B', 30);
end

function close_claw(brick)
    brick.MoveMotor('B', -30);
end

function stop_claw(brick)
    brick.StopMotor('B', 'Brake'); % Stop the claw motor
end
