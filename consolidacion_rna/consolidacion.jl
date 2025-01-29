# To install package run
#] add CSV, DataStructures, StatsBase, BenchmarkTools
using CSV, DataStructures, StatsBase, BenchmarkTools, DelimitedFiles
# using Revise
# includet("test_aggregation.jl")


function read_csv(filename)
	#rows=CSV.Rows(filename, types=[String,String,String], strict=true, stringtype=String)
	lines = eachline(filename)
	first(lines)
	lines
	#for line in lines
	#	return line
	#end
	#readdlm("reads.txt",'\t',String;skipstart=1)
	
end

function split_row(row)
	split(row,'\t')
end 

d_cell = 1:16
d_umi = 18:29
d_clone_id = 31:60

function to_record(line::String)
	d_cell = 1:16
	d_umi = 18:29
	d_clone_id = 31:60
	[line[d_cell]*line[d_umi],line[d_clone_id]]
end

function to_record(row::Vector{String})
	#row::CSV.Row2{Any,String}
	#val = getfield(row,:values)::Vector{String}
	String[row[1]*row[2],row[3]]
	#String[row[1]*row[2],row[3]]
end

function to_groups(records)
	gen() = DefaultDict{String,Int64}(0)
	d = DefaultDict{String,DefaultDict{String,Int64}}(gen)
	for (k,v) in records
		d[k][v] += 1
	end
	d
end

function consolidate(obs, counts)
	for c in counts
	  for k in keys(c)
	   c[k] = 0
	  end
	end

	
	for (cell, count) in obs
		for i in 1:length(counts)
		  counts[i][cell[i]] = count
		end
	end

	for c in counts
	 c['0'] *= 0.1
	 c['-'] *= 0.1
	end
	
	join(argmax(c) for c in counts)
end

function process(filename)
	d = read_csv(filename) |> x -> map(to_record,x) |> to_groups
	counts = [DefaultDict{Char,Float64}(0) for _ in 1:30]
	SortedDict(k=>consolidate(v, counts) for (k,v) in d)
end