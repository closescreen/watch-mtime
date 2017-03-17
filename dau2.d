// rdmd dau2.d -i1 --deb dau2.d "dmd dau2.d"
void main(string[] args)
{
  import std.stdio, std.getopt, std.process, std.c.stdlib; 
  
  auto deb=false, interval=1; 
  auto opts = getopt( args,
    "i|interval", "interval in seconds between checking", &interval,
    "d|deb|debug", "show debug messages to stderr", &deb );
  
  if ( opts.helpWanted ){
    defaultGetoptPrinter( "Usage: ", opts.options );
    exit(0);
  }
    
  if ( args.length < 3 ){
  	stderr.writeln("Too few parameters");
  	exit(1);
  }
  
  auto cmd = args[$-1], files = args[1..$-1];
  deb && stderr.writef("watch files: %s;\ncmd = \"%s\";\ninterval = %d sec;\n", files, cmd, interval);
}


//auto path = environment["PATH"];
/*
auto sh = environment.get("SHELL", "/bin/sh");

environment["foo"] = "bar";

auto dmd = execute(["dmd", "myapp.d"]);
if (dmd.status != 0) writeln("Compilation failed:\n", dmd.output);

auto ls = executeShell("ls -l");
if (ls.status != 0) writeln("Failed to retrieve file listing");
else writeln(ls.output);

auto logFile = File("myapp_error.log", "w");

// Start program, suppressing the console window (Windows only),
// redirect its error stream to logFile, and leave logFile open
// in the parent process as well.
auto pid = spawnProcess("myapp", stdin, stdout, logFile,
                        Config.retainStderr | Config.suppressConsole);
scope(exit)
{
    auto exitCode = wait(pid);
    logFile.writeln("myapp exited with code ", exitCode);
    logFile.close();
}

string url = "http://dlang.org/";
executeShell(escapeShellCommand("wget", url, "-O", "dlang-index.html"));

executeShell(
    escapeShellCommand("curl", "http://dlang.org/download.html") ~
    "|" ~
    escapeShellCommand("grep", "-o", `http://\S*\.zip`) ~
    ">" ~
    escapeShellFileName("D download links.txt"));

writefln("Current process ID: %d", thisProcessID);

auto p = pipe();
p.writeEnd.writeln("Hello World");
p.writeEnd.flush();
assert (p.readEnd.readln().chomp() == "Hello World");

// Use cURL to download the dlang.org front page, pipe its
// output to grep to extract a list of links to ZIP files,
// and write the list to the file "D downloads.txt":
auto p = pipe();
auto outFile = File("D downloads.txt", "w");
auto cpid = spawnProcess(["curl", "http://dlang.org/download.html"],
                         std.stdio.stdin, p.writeEnd);
scope(exit) wait(cpid);
auto gpid = spawnProcess(["grep", "-o", `http://\S*\.zip`],
                         p.readEnd, outFile);
scope(exit) wait(gpid);

*/
