#include <iostream>
#include <fstream>
#include <string>
#include <ctime>
#include <iomanip>
#include <sstream>

void printInFrame(const std::string& str) {
    // Calculate the width of the frame based on the length of the string
    int frameWidth = str.length() + 4; // 2 '#' on each side

    // Print the top border
    std::cout << std::setw(frameWidth) << std::setfill('#') << '#' << std::endl;

    // Print the string with borders
    std::cout << '#' << ' ' << str << ' ' << '#' << std::endl;

    // Print the bottom border
    std::cout << std::setw(frameWidth) << std::setfill('#') << '#' << std::endl;
}

std::string time2String(const std::time_t& time, const std::string& format) {
    char buffer[100]; // Adjust the size as needed
    std::tm* timeStruct = std::gmtime(&time);
    std::strftime(buffer, sizeof(buffer), format.c_str(), timeStruct);
    return std::string(buffer);
}

std::string tm2String(const std::tm& time, const std::string& format) {
    char buffer[100]; // Adjust the size as needed
    std::strftime(buffer, sizeof(buffer), format.c_str(), &time);
    return std::string(buffer);
}

int sec2day(int sec) {
    return sec / (24 * 3600);
}

std::string int2strFormat(int num, int width = 4) {
    // Using ostringstream to convert the integer to a string with leading zeros
    std::ostringstream oss;
    oss << std::setw(4) << std::setfill('0') << num;

    return oss.str();
}
std::string int2str(int num, int precision = 1) {
    std::string num_str = std::to_string(num);
    for (int i = 0; i < precision; ++i) {
        if(i == 0)
            num_str += ".";

        num_str += "0";
    }
    return num_str;
}

std::time_t addOneDay(const std::time_t& time) {
    std::tm timeStruct = *std::gmtime(&time); // Convert time_t to tm

    if (timeStruct.tm_mday == 31) {
        timeStruct.tm_mday = 1;
        if (timeStruct.tm_mon == 11) {
            timeStruct.tm_year++;
            timeStruct.tm_mon = 0;
        } else {
            timeStruct.tm_mon++;
        }
    } else {
        timeStruct.tm_mday++;
    }

    return (std::mktime(&timeStruct) - timezone); // Convert tm back to time_t
}

std::time_t addOneMonth(const std::time_t& time) {
    std::tm timeStruct = *std::gmtime(&time); // Convert time_t to tm

    // Add one to the month, adjust year if necessary
    if (timeStruct.tm_mon == 11) {
        timeStruct.tm_year++;
        timeStruct.tm_mon = 0;
    } else {
        timeStruct.tm_mon++;
    }

    return (std::mktime(&timeStruct) - timezone); // Convert tm back to time_t
}

std::time_t addOneYear(const std::time_t& time) {
    std::tm timeStruct = *std::gmtime(&time); // Convert time_t to tm
    timeStruct.tm_year++;

    return (std::mktime(&timeStruct) - timezone); // Convert tm back to time_t
}

int main(int argc, char* argv[]) {
    std::string casename_afi                  = {};
    std::string fieldManagmentStrategyFM_file = {};

    // Check if a path argument is provided
    if (argc != 3) {
        casename_afi        = "../../Examples/Brine_MultipleComponent.afi";
        fieldManagmentStrategyFM_file = "../../Examples/Brine_MultipleComponent_ECL2IX_FM.ixf";
    } else {
        casename_afi                  = argv[1];
        fieldManagmentStrategyFM_file = argv[2];
    }

    // Print the provided path within a frame
    printInFrame(casename_afi);
    printInFrame(fieldManagmentStrategyFM_file);

    // input simulation parameters
    std::string formatOut           = "%d-%b-%Y";
    std::tm startSimulationTime     = {0, 0, 0, 1, 0, 2000-1900}; // The first simulation time, where the model initialized
    std::time_t startSimulationTime_t = std::mktime(&startSimulationTime) - timezone; // change the timezone to Coordinated Universal Time (UTC)
    std::tm initialRestartTime      = {0, 0, 0, 1, 0, 2001-1900}; // The first restart time must be run manually by the user
    std::time_t initialRestartTime_t= std::mktime(&initialRestartTime) - timezone; // change the timezone to Coordinated Universal Time (UTC)
    std::time_t startRestartTime_t  = addOneMonth(initialRestartTime_t);
    std::tm endRestartTime          = {0, 0, 0, 1, 0, 2002-1900};
    std::time_t endRestartTime_t    = std::mktime(&endRestartTime) - timezone; // change the timezone to Coordinated Universal Time (UTC)

    // run the simulation
    int i = 1;
    while (startRestartTime_t <= endRestartTime_t) {
        printInFrame("Starting new time step");
        printInFrame("Current time step: " + time2String(startRestartTime_t, formatOut));

        // updating field management strategy file (adding a new timestep)
        // read field management strategy file
        std::ifstream fmFile(fieldManagmentStrategyFM_file);
        if (!fmFile.is_open()) {
            std::cerr << "Unable to open the field management strategy file for appending the new time step." << std::endl;
            return 1;
        }

        std::string fmContent((std::istreambuf_iterator<char>(fmFile)), std::istreambuf_iterator<char>());
        fmFile.close();

        // find the last time step
        size_t pos = fmContent.find("END_INPUT");
        fmContent.replace(pos, 9, "DATE  \"" + time2String(startRestartTime_t, formatOut) + "\"  SAVE_RESTART    \"*." +int2strFormat(i) + "\"");

        // write the new time step
        std::ofstream fmFileWrite(fieldManagmentStrategyFM_file);
        if (!fmFileWrite.is_open()) {
            std::cerr << "Unable to open the field management strategy file for appending the new time step." << std::endl;
            return 1;
        }

        fmFileWrite << fmContent;
        fmFileWrite << std::endl;
        fmFileWrite << "#TIME   " << sec2day(std::difftime(startRestartTime_t, startSimulationTime_t));
        fmFileWrite << std::endl;
        fmFileWrite << std::endl;
        fmFileWrite << "END_INPUT";
        fmFileWrite.close();

        // update the afi file
        std::ifstream afiFile(casename_afi);
        std::string afiContent((std::istreambuf_iterator<char>(afiFile)), std::istreambuf_iterator<char>());
        afiFile.close();

        int prevTime = sec2day(std::difftime(initialRestartTime_t, startSimulationTime_t));
        int curTime = sec2day(std::difftime(startRestartTime_t, startSimulationTime_t));
        size_t posAfi = afiContent.find(int2str(prevTime));
        afiContent.replace(posAfi, int2str(curTime).length(), int2str(curTime));

        std::ofstream afiFileWrite(casename_afi);
        afiFileWrite << afiContent;
        afiFileWrite.close();

        // run the simulation
        std::string command = "eclrun ix " + casename_afi;
        system(command.c_str());

        // reading results from the restart file
        // update the start time
        initialRestartTime_t = startRestartTime_t;
        startRestartTime_t = addOneMonth(initialRestartTime_t);
        if (startRestartTime_t == endRestartTime_t) {
            std::cout << "----Simulation run successfully!----" << std::endl;
            break;
        } else if (startRestartTime_t > endRestartTime_t) {
            startRestartTime_t = endRestartTime_t;
        }
        i++;
        printInFrame("Finished one time step");
    }

    printInFrame("Simulation run successfully!");

    return 0;
}
