const pathLib = require("path");
const { spawnSync } = require("node:child_process");

const RETURN_SUCCESS = 0;
const RETURN_ERROR = 100;
const RETURN_WARNING = 101;
const RETURN_ERROR_HEADLESS_NOT_SUPPORTED = 103;
const RETURN_ERROR_GODOT_VERSION_NOT_SUPPORTED = 104;




function console_info(message) {
  console.log('\x1b[94m', message, '\x1b[0m');
}

function console_warning(message) {
  console.error('\x1b[94m', message, '\x1b[0m');
}


async function runTests() {
  try {
    const project_dir = '.'
    const paths = "test"
    const arguments = ''
    const timeout = 10
    const retries = 0
    const warningsAsErrors = true
    // Split by newline or comma, map, trim, and filter empty strings
    const pathsArray = paths.split(/[\r\n,]+/).map((entry) => entry.trim()).filter(Boolean);


    const args = [
      "--auto-servernum",
      "./addons/gdUnit4/runtest.sh",
      "--audio-driver Dummy",
      "--display-driver x11",
      "--rendering-driver opengl3",
      "--single-window",
      "--continue",
      ...pathsArray.map((path) => `--add ${path}`),
      `${arguments}`
    ];

    console_info(`project_dir: ${project_dir}`);
    console_info(`arguments: ${arguments}`);
    console_info(`timeout: ${timeout}m`);
    console_info(`retries: ${retries}`);
    console_info(`warningsAsErrors: ${warningsAsErrors}`);


    let exitCode = 0;

    const child = spawnSync("godot", args, {
      cwd: ".",
      timeout: timeout * 1000 * 60,
      encoding: "utf-8",
      shell: true,
      stdio: ["inherit", "inherit", "inherit"],
      env: process.env,
    });

    // Handle spawn errors
    if (child.error) {
      throw Error(`Run Godot process ends with error: ${child.error}`);
    }

    exitCode = child.status;


    switch (exitCode) {
      case RETURN_SUCCESS:
        console_info(`The tests was successfully with exit code: ${exitCode}`);

        break;
      case RETURN_ERROR:
        throw Error(`The tests was failed after ${retries} retries with exit code: ${exitCode}`);
      case RETURN_WARNING:
        if (warningsAsErrors === true) {
          throw Error(`Tests completed with warnings (treated as errors)`);
        } else {
          console_warning('Tests completed successfully with warnings');
        }
        break;
      case RETURN_ERROR_HEADLESS_NOT_SUPPORTED:
        throw Error('Headless mode not supported');
        break;
      case RETURN_ERROR_GODOT_VERSION_NOT_SUPPORTED:
        throw Error('Godot version not supported');
      default:
        throw Error(`Tests failed with unknown error code: ${exitCode}`);
    }

    return exitCode;
  } catch (error) {
    throw Error(`Tests failed: ${error.message}`);
  }
}

runTests()