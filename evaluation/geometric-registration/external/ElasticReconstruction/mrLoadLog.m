function [ traj, success ] = mrLoadLog( filename )
    
    % Initialize traj as an empty struct array
    traj = struct('info', {}, 'trans', {});
    success = false; % Flag to indicate if reading was successful

    % Attempt to open the file
    fid = fopen( filename, 'r' );

    % Check if the file was successfully opened
    if fid == -1
        disp(['Error opening file: ', filename]);
        return;
    end

    % Read the data
    k = 1;
    x = fscanf( fid, '%d', [1 3] );
    while ( size( x, 2 ) == 3 )
        m = fscanf( fid, '%f', [4 4] );
        traj( k ) = struct( 'info', x, 'trans', m' );
        k = k + 1;
        x = fscanf( fid, '%d', [1 3] );
    end
    fclose( fid );
    %disp( [ num2str( size( traj, 2 ) ), ' frames have been read.' ] );

    % Check if any frames were read
    if isempty(traj)
        return;
    end
    
    % If no problem was found
    success = true; % Indicate successful reading
end
