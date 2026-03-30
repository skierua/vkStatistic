# vkStat

## Statistics/Analysis for POS Terminal Database

A cross-platform tool designed for analyzing and gathering statistics from POS terminal databases.

### Supported OS
*   **Linux**
*   **Windows**
*   **macOS**

*Compilation and testing were performed using the **Qt 6.10** environment.*

### Local Storage Database
*   **SQLite3**

### Working Directory Structure

#### Linux | Windows
```text
./app
  └── /data/

```
#### macOS
The application uses a **bundle**, which maintains the same internal working directory structure.

### Known Issuases ###
* **None identified**

### Getting Started

#### Prerequisites
- **Qt 6.10** or higher
- **C++ Compiler** (GCC for Linux, MSVC/MinGW for Windows, Clang for macOS)
- **CMake** (3.16+)

#### Build Instructions
**Bash:**
   ```bash
   git clone https://github.com/skierua/vkStatistic.git
   cd vkStatmkdir build && cd build
   cmake ..
   cmake --build .
   ```
Or use Qt Creator to build `CMakeLists.txt`

### Usage

Once the application is launched, ensure your database files are placed in the /data/ directory relative to the executable. 
Or just place it into appvkPOS5 working directory for connection to current database.