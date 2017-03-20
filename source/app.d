void main(string[] args)
{
  import std.stdio, std.getopt, std.process, std.c.stdlib; // несколько импортов одной строкой
  import core.thread, std.file, std.range.primitives; 
  import colorize : fg, color, cwritef, cwritefln; // импорт конкретных имен из модуля
  import std.datetime;
  
    
  auto deb=false, interval=1, icolr="cyan", wcolr="yellow", okcolr="green"; // объявление нескольких переменных 
  auto opts = getopt( args, // анализ опций из args 
    "i|interval", "interval in seconds between checking", &interval, // i|interval - значит или -i или --interval
    "d|deb|debug", "show debug messages to stderr", &deb, 
    "icolor" , "info color", &icolr,
	"wcolor" , "warnings color", &wcolr,
	"okcolor", "ok color", &okcolr,
    ); // ссылается на значение bool, поэтому работает как флаг
  
  if ( opts.helpWanted ){ // если пользователь использовал -h|--help
    defaultGetoptPrinter( "Usage: ", opts.options ); // печатает opts 
    exit(0);
  }
    
  if ( args.length < 3 ){
  	stderr.writeln("Too few parameters"); // синтаксический сахар для: writeln( stderr, "Too few parameters");
  	exit(1); // выйти с плохим кодом возврата
  }
  
  auto cmd = args[$-1], files = args[1..$-1]; // последний аргумент командной строки - команда, остальное - отслеживаемые файлы
  auto path = environment.get("PATH", "not present"); // пример доступа к переменным окружения

  // Ниже использован цветной вывод на stdout с использованием стороннего модуля colorize
  // Кроме того что colorize импортирован, он указан как зависимость в dub.json такой записью: "colorize": "~>1.0.5" 
  // cwritef из colorize - аналог writef из std.stdio. Правила форматированного вывода те же. 
  deb && cwritef("watch files: %s;\ncmd: \"%s\";\ninterval: %d sec;\nPATH: %s;\n".color(icolr), files, cmd, interval, path);
  
  auto cnt = 0;
  SysTime[string] file_times;  // создать х-м файл=>время. Тип SysTime подсмотрен в доке по std.file.

  while(true){
	string[] changed; // массив строк

    foreach (f; files){
      auto lm = timeLastModified(f); // функция из std.file
//      if ( f in file_times ){ // оператор in в отношении словаря прверяет наличие ключа
//        file_times[f] == lm || ( changed ~= f ); 
//      }else{
//        changed ~= f; // добавление в массив
//      }
	  if ( get( file_times, f, SysTime() ) != lm ){
		changed ~= f;
    	file_times[f] = lm; // присвоение элементу массива
  	  }	
    }
	
	if ( !empty(changed) ){ // проверка массива на "не пусто"
	  cnt++;
	  cwritef("\n %d => ".color(icolr) , cnt);
	  deb && cwritef("%s changed\n\"%s\"".color(icolr), changed, cmd);
	  auto pid = spawnShell( cmd); // асинхронный запуск shell-процесса 
	  auto status = wait(pid); // код возврата
	  auto c = okcolr;
	  if (status>0) c = wcolr; // одно выражение в блоке может быть без фигурных скобок
	  cwritefln( "status: %d\n".color(c), status );
    }
    Thread.sleep( dur!("seconds")( interval ) ); // спать секунду
  }
}


/*

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
