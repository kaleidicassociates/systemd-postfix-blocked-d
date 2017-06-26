#!/usr/bin/dmd
import std.stdio;
import std.process;
import std.string;
import std.algorithm;
import std.array:array;

int main(string[] args)
{
	auto result=executeShell( "journalctl -r  -u postfix | grep 'to=' | grep blocked");
	if (result.status!=0)
	{
		writefln("failed:\n%s",result.output);
		return(-1);
	}

	auto froms=result.output.splitLines
			.map!(a=>a.extractFrom)
			.filter!(a=>a.length>0)
			.array
			.sort
			.uniq
			.array;
	foreach(from;froms)
		writefln("%s",from);
	return 0;
}

string extractFrom(string line)
{
	line=line.strip.toLower;
	auto i=line.indexOf("to");
	if ((i==-1)||(i==line.length-1))
		return "";
	auto j=line[i+1..$].indexOf("<");
	if ((j==-1)||(j+i+2>=line.length-1))
		return "";
	line=line[i+j+2..$];
	i=line.indexOf(">");
	if (i==-1)
		return "";
	return line[0..i];
}
