function I_zk = calculo_izk(dy,X_)

    datos = size(X_, 2);
    reglas = size(X_, 3);
    
    I_zk = zeros(datos, 1);
    
    
    % Calcular I_zk usando la ecuación 7.9
    for i = 1:datos
        suma = 0;
        norma = 0;
        act = zeros(1,reglas);
        for j = 1:reglas
            % Obtenemos la activación de la regla
            act(j) = prod(X_(:,i,j));
            norma = norma + act(j);
        end
        
        for j = 1:reglas
   try     
           suma = suma + (act(j)/norma)*sqrt(dy(i,j));
   catch ME
            warning('Ha ocurrido un error. Ingresando al modo de depuración...');
            disp(ME.message); % Mostrar mensaje de error
            disp('Use el comando "return" para continuar con la siguiente simulación.');
            keyboard; % Entrar en modo de depuración
    end         
        end
        
        I_zk(i) = suma;
    end
end
