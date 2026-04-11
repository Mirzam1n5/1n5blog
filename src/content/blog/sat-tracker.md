---
title: "My satellite tracker"
date: 2026-04-03
description: "Did you know I like satellites?"
tags: ["satellites"]
---

Hi, in this post I'll talk about how I wrote a console program for tracking satellites in C++. It shows the coordinates of a selected satellite, identifies which one is closest to the user, and alerts when a satellite passes over the user.

Satellites move in orbits. To determine where a satellite is located, we use TLE(Two-Line Element set) data. This is a set of "instructions" for calculating an orbit, including altitude, inclination, velocity, and more.

The satellites.txt file contains thousands of TLE records, one for each active satellite. Each entry consists of three lines: the name of the satellite and two lines with orbital parameters.

To calculate the satellite's current position, you need fairly complex math. For this, I use the libsgp4 library, which implements the SGP4(Simplified General Perturbations) algorithm. I provide it with the TLE data and the current time, and it returns the satellite's position in space.

Satellites move in absolute coordinates (kilometers from the center of the Earth), but I need to know where they are relative to me; whether they are far or close, above or below the horizon. To do this, the program asks for my coordinates (latitude, longitude, and altitude).

Data structure:

```cpp
struct Satellite {
    std::string name;       // satellite name
    libsgp4::Tle tle;       // orbital data
    libsgp4::SGP4 sgp4;     // the object for calculating the position
};
```

Function load_satellites():

```cpp
void load_satellites(std::vector<Satellite>& satellites) {
    std::ifstream readfile("satellites.txt");

    if(!readfile.is_open()) {
        std::cerr << "Cant't open satellites.txt!" << std::endl;
    }

    std::string name, line1, line2;
    while (std::getline(readfile, name)) {
        std::getline(readfile, line1);
        std::getline(readfile, line2);

        name = trim(name);
        line1 = trim(line1);
        line2 = trim(line2);

        if (name.empty() || line1.empty() || line2.empty()) {
        continue;
        }

        try {
        libsgp4::Tle tle(name, line1, line2);
        libsgp4::SGP4 sgp4(tle);
        satellites.push_back({name, tle, sgp4});
        } catch (const libsgp4::TleException& e) {
        std::cerr << "TLE error:" << name << ": " << e.what() << std::endl;
        } catch (const std::exception& e) {
        std::cerr << "General error: " << e.what() << std::endl;
        }

    }
}
```

This function opens the satellites.txt file and reads it line by line. For each satellite, it creates a TLE object, creates an SGP4 object for calculations, and adds it to the satellite vector. It removes extra spaces using another function, trim:

```cpp
std::string trim(const std::string& str) {
    auto start = str.begin();

    while (start != str.end() && std::isspace(*start)) {
        start++;
    }

    auto end = str.end();

    do {
        end--;
    } while (std::distance(start, end) > 0 && std::isspace(*end));

    return std::string(start, end + 1);
}
```

If a TLE is broken or incorrect, the program simply skips that satellite and continues (try-catch).

Function get_observer_location():

```cpp
libsgp4::Observer get_observer_location() {
    double latitude, longitude, altitude_m, altitude_km;

    std::cout << "Enter your latitude (degrees, -90 to 90): " << std::endl;
    std::cin >> latitude;

    std::cout << "Enter your longitude (degrees, -180 to 180): " << std::endl;
    std::cin >> longitude;

    std::cout << "Enter your altitude (meters, or 0): " << std::endl;
    std::cin >> altitude_m;

    altitude_km = altitude_m / 1000.0;

    libsgp4::CoordGeodetic coord(latitude, longitude, altitude_km);
    libsgp4::Observer observer(coord);

    return observer;
}
```

This function simply asks the user for their coordinates and creates an Observer object, which is an "observer" at the user's location on Earth.

The main tracking loop - track_satellites():

This function runs continuously, updating satellite positions every 5 seconds:

```cpp
void track_satellites(std::vector<Satellite>& satellites, libsgp4::Observer& observer) {
    while (true) {
        libsgp4::DateTime now = libsgp4::DateTime::Now();
        
        double min_range = std::numeric_limits<double>::infinity();
        std::string closest_name = "";
        double closest_elevation = 0.0;
        double closest_azimuth = 0.0;
        double closest_range = 0.0;
        
        for (const auto& sat : satellites) {
            try {
                libsgp4::DateTime epoch = sat.tle.Epoch();
                libsgp4::TimeSpan diff = now - epoch;
                double minutes = diff.TotalMinutes();
                
                libsgp4::Eci eci = sat.sgp4.FindPosition(minutes);
                
                libsgp4::CoordTopocentric topo = observer.GetLookAngle(eci);
                
                double range = topo.range;      
                double elevation = topo.elevation * 180.0 / M_PI;  
                double azimuth = topo.azimuth * 180.0 / M_PI;      
                
                if (range < min_range) {
                    min_range = range;
                    closest_name = sat.name;
                    closest_elevation = elevation;
                    closest_azimuth = azimuth;
                    closest_range = range;
                }
                
            } catch (const std::exception& e) {
                continue;
            }
        }
        
        std::cout << "\n========================================" << std::endl;
        std::cout << R"(
         _____  _____  ____    ____  _____  _____  _____  __ ___ _____  _____  ___ 
        /  ___>/  _  \/    \  /    \/  _  \/  _  \/     \|  |  //   __\/  _  \/   \
        |___  ||  _  |\-  -/  \-  -/|  _  <|  _  ||  |--||  _ < |   __||  _  <\___/
        <_____/\__|__/ |__|    |__| \__|\_/\__|__/\_____/|__|__\\_____/\__|\_/<___>                                                                
        )" << std::endl;
        std::cout << "========================================" << std::endl;
        std::cout << "Time: " << now.ToString() << std::endl;
        std::cout << "\nNearest satellite: " << closest_name << std::endl;
        std::cout << "Distance: " << closest_range << " km" << std::endl;
        
        if (closest_elevation > 0) {
            std::cout << "\nIt's flying by now!" << std::endl;
            std::cout << "Height above the horizon: " << closest_elevation << "°" << std::endl;
            std::cout << "Azimuth: " << closest_azimuth << "°" << std::endl;
        } else {
            std::cout << "\n(Under the horizon - not visible)" << std::endl;
        }
        
        std::cout << "========================================\n" << std::endl;
        
        std::this_thread::sleep_for(std::chrono::seconds(5));
    }
}
```

1. Gets the current time
2. For each satellite:
   - Calculates how many minutes have passed since the TLE epoch
   - Gets the satellite's position in space (ECI coordinates)
   - Converts to topocentric coordinates (relative to the observer)
   - Extracts: distance (range), elevation angle, and azimuth
3. Finds the closest satellite
4. Displays results and checks if it's currently overhead (elevation > 0°)

Key transformations:
- **ECI (Earth-Centered Inertial)** - absolute position from Earth's center
- **Topocentric** - position relative to observer (range, elevation, azimuth)
- Angles are converted from radians to degrees for readability

### Results

The program successfully tracks thousands of satellites in realtime. Currently, Starlink satellites are most frequently detected as the closest, there are thousands of them orbiting at ~550km altitude. Though there are other more interesting ones.

![sat-tracker](/gallery/sttrex.jpg)