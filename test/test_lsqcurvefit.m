function test_lsqcurvefit()
%
% TEST_lsqcurvefit: Comprehensive test suite for lsqcurvefit function
%
% Author: Dr. Tanuj Puri
% Date: 01/2014
% Warning: This is an untested code/implementation and should be used
% with caution in clinical and pre-clinical settings.
%

  pass = 0; fail = 0;

  function report(name, ok)
    if ok
      printf("PASS: %s\n", name); pass += 1;
    else
      printf("FAIL: %s\n", name); fail += 1;
    end
    disp("----------------")
  end

  try
    %% 1. Linear model, well-behaved
    model = @(p, x) p(1)*x + p(2);
    xdata = (0:5)';
    ydata = 3*xdata + 2;
    x0 = [0; 0];
    [p, ~] = lsqcurvefit(model, x0, xdata, ydata);
    report("Linear model exact", norm(p - [3; 2]) < 0.1);

    %% 2. Exponential model, noisy data
    model = @(p, x) p(1)*exp(p(2)*x);
    xdata = (0:0.2:2)';
    ydata = 2 * exp(1.5 * xdata) + 0.05 * randn(size(xdata));
    x0 = [1; 1];
    [p, ~] = lsqcurvefit(model, x0, xdata, ydata);
    report("Exponential noisy fit", abs(p(1) - 2) < 0.5 && abs(p(2) - 1.5) < 0.5);

    %% 3. Sinusoidal model, bounded fit
    model = @(p, x) p(1)*sin(p(2)*x);
    x = linspace(0, 2*pi, 100)';
    y = 2 * sin(3*x);
    x0 = [1; 1];
    lb = [0; 0];
    ub = [10; 10];
    [p, ~] = lsqcurvefit(model, x0, x, y, lb, ub);
    report("Sine fit bounded", abs(p(1) - 2) < 0.5 && abs(p(2) - 3) < 0.5);

    %% 4. Poor initial guess
    model = @(p, x) p(1)*x + p(2);
    xdata = (1:10)';
    ydata = 5*xdata + 7;
    x0 = [-1000; -1000];
    [p, ~] = lsqcurvefit(model, x0, xdata, ydata);
    report("Poor initial guess", norm(p - [5; 7]) < 1.0);

    %% 5. Bounds exclusion test
    model = @(p, x) p(1)*x;
    xdata = (0:10)';
    ydata = 10*xdata;
    x0 = [1];
    lb = [9]; ub = [9.1];
    [p, ~] = lsqcurvefit(model, x0, xdata, ydata, lb, ub);
    report("Bounds enforced", p >= 9 && p <= 9.1);

    %% 6. Degenerate model (flat line)
    model = @(p, x) p(1) * ones(size(x));
    ydata = ones(10, 1);
    xdata = (1:10)';
    [p, ~] = lsqcurvefit(model, 0.5, xdata, ydata);
    report("Flat model", abs(p - 1) < 0.1);

    %% 7. Fail case: wrong dimensions
    model = @(p, x) p(1)*x;
    try
      [~, ~] = lsqcurvefit(model, [1 2], [1 2 3], [1 2]);
      report("Wrong dim fail", false);
    catch
      report("Wrong dim fail", true);
    end

    %% 8. Fail case: NaNs in data
    xdata = (1:10)';
    ydata = 3*xdata + 2;
    ydata(5) = NaN;
    try
      [~, ~] = lsqcurvefit(@(p,x) p(1)*x + p(2), [1; 1], xdata, ydata);
      report("NaN input fail", false);
    catch
      report("NaN input fail", true);
    end

    %% 9. Fail case: fun doesn't match x size
    model = @(p, x) p(1)*x(1);  % wrong size output
    try
      [~, ~] = lsqcurvefit(model, [1], [1 2 3]', [1 2 3]');
      report("Model mismatch fail", false);
    catch
      report("Model mismatch fail", true);
    end

    %% 10. No bounds and minimal options
    model = @(p, x) p(1)*x + p(2);
    x0 = [1; 1];
    [p, ~] = lsqcurvefit(model, x0, (1:5)', (2*(1:5)' + 1));
    report("No bounds basic", norm(p - [2; 1]) < 0.1);

  catch err
    disp(err.message);
    disp(err.stack);
    printf("FATAL ERROR in test execution.\n");
  end

  printf("\nSUMMARY: Passed %d | Failed %d\n", pass, fail);
  
end% end main function
