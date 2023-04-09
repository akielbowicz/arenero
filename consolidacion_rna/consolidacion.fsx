module Consolidate
open System.IO

let readFile path = 
    seq {
        use reader = new StreamReader(File.OpenRead(path))
        while not reader.EndOfStream do
            reader.ReadLine()
    }

type Rec = {cellId:string;cloneId:string}

let toRecord (line: string)= 
    line 
    |> (fun l -> l.Split("\t")) 
    |> (fun r -> {cellId = r[1]+ r[0]; cloneId= r[2]})

let increaseCount e (map:Map<string,int>) =
    map |> Map.change e (fun s -> 
        match s with 
        | Some x -> Some (x+1)
        | None -> Some (1))

let update cellId element map = 
    map |> Map.change cellId (fun s ->
        match s with
        | Some x -> Some (increaseCount element x)
        | None -> Some (Map [(element,1)]))
    
let toGroups (seq: Rec seq) =
    seq |> Seq.fold (fun acc r -> update r.cellId r.cloneId acc) Map.empty

let group data= data |> Seq.skip 1 |> Seq.map toRecord |> toGroups 

let myfun2 (a: Map<string,int>) ix = 
    a |> Map.toSeq 
    |> Seq.map (fun (k, v) -> (k.[ix],v)) 

let countMap (map:Map<char,float>) (key:char, count:int) = 
    let inc = match key with
        | '-' -> 0.1
        | _ -> 1.0
    map |> Map.change key (fun k ->
        match k with 
        | Some x -> Some (x+inc*(float count))
        | None -> Some (inc*(float count)))

let count seq =
    seq |> Seq.fold (fun s e -> countMap s e) Map.empty

let argmax map = 
    map |> Map.fold (fun (k,v) nk nv ->
     if v > nv then (k,v) else (nk,nv) ) ('-',0.0)
     |> fun (k,v) -> k 


let theFunc arr ix =
    myfun2 arr ix 
    |> count
    |> argmax

let consolidate map =
    Seq.fold (fun x ix -> x + (theFunc map ix).ToString()) "" [0..29]

let consolidateAll map=
    map |> Map.map ( fun n s -> (consolidate s) )

// let data = readFile "reads.txt"
// let result = data |> group |> consolidateAll
