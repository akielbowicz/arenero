# using HTTP
# using Gumbo, Cascadia

# url= "https://www.youtube.com/@TheJuliaLanguage/search?query=juliacon%202024"

# sitio = HTTP.get(url)

# html_str = String(sitio.body)

html_str = open(io->read(io, String), "YouTube.htm")

ejemplo = """
            ytd-item-section-renderer.style-scope:nth-child(2) > div:nth-child(3) > ytd-video-renderer:nth-child(1) > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > div:nth-child(1) > h3:nth-child(1) > a:nth-child(2)

<a id="video-title" class="yt-simple-endpoint style-scope ytd-video-renderer" title="JuliaCon 2024 | Else Room | Day 1" aria-label="JuliaCon 2024 | Else Room | Day 1 by The Julia Programming Language 1,509 views Streamed 3 days ago 7 hours, 44 minutes" href="/watch?v=LNfSeco0q04">
            <yt-icon id="inline-title-icon" class="style-scope ytd-video-renderer" hidden=""><!--css-build:shady--><!--css-build:shady--></yt-icon>
            <yt-formatted-string class="style-scope ytd-video-renderer" aria-label="JuliaCon 2024 | Else Room | Day 1 by The Julia Programming Language 1,509 views Streamed 3 days ago 7 hours, 44 minutes">JuliaCon 2024 | Else Room | Day 1</yt-formatted-string>
          </a>
          """

pattern = r"title=\"(JuliaCon 2024.*)\" aria.*href=\".*watch\?v=(.*)\">"

match(pattern, ejemplo)

x = collect(map(m->m.captures, eachmatch(pattern, html_str)));

videos = map(s-> "https://www.youtube.com/watch?v=$(s[2])", x)

# Get info from Pretalx api
talks_endpoint = "https://pretalx.com/api/events/juliacon2024/talks/"
rooms_endpoint = "https://pretalx.com/api/events/juliacon2024/rooms/"

using JSON3
# talks_str = String(HTTP.get(talks_endpoint; query=["limit"=>500]).body)
talks_str = open(io->read(io, String), "talks.json")
talks = JSON3.read(talks_str)
talks_info = collect(map(t-> Dict(:title=>t[:title],:room=>t[:slot][:room][:en], :start=> t[:slot][:start]), talks.results ))
sort!(talks_info, by=t->(t[:room],t[:start]))
# write("talks.json", talks_str)

by_room_str = open(io->read(io, String), "by_room.json")
by_room = JSON3.read(by_room_str)

to_dt(str) = parse(DateTime, split( str, "+02:00")[1], Dates.ISODateTimeFormat)
# talk_name = Symbol("REPL (2, main stage)")
# talk_name = Symbol("For Loop (3.2)")

room_name = first(filter(contains("Method")∘String, keys(by_room)))
days = Dict(1=>"07-10",2=> "07-11",3=>"07-12")
day = days[2]
filtered_talks = filter(t-> occursin(day,t[:start]), by_room[room_name])


times = map(t-> to_dt(t[:start]), filtered_talks)
start_time = floor(times[1], Dates.Hour)

# ####################
using VideoIO

vds = [
  # ("JuliaCon 2024 | Else Room | Day 1", "https://www.youtube.com/watch?v=LNfSeco0q04")
  # ("JuliaCon 2024 | If Room | Day 1", "https://www.youtube.com/watch?v=6ES-yZke5DQ")
  # ("JuliaCon 2024 | Method Room | Day 1", "https://www.youtube.com/watch?v=1c4TTosBzzY")
  # ("JuliaCon 2024 | For Loop Room | Day 1", "https://www.youtube.com/watch?v=HCSdOMnzcnY")
  # ("JuliaCon 2024 | While Loop Room | Day 1", "https://www.youtube.com/watch?v=-2OkeCpRB-Y")
  # ("JuliaCon 2024 | REPL Main Stage | Day 1", "https://www.youtube.com/watch?v=OQnHyHgs0Qo")
# ("JuliaCon 2024 | Function Room | Day 1", "https://www.youtube.com/watch?v=V7FWl4YumcA")

# ("JuliaCon 2024 | For Loop Room | Day 2", "https://www.youtube.com/watch?v=ZKt0tiG5ajw")
# ("JuliaCon 2024 | Method Room | Day 2", "https://www.youtube.com/watch?v=gbtTJQFVijM")
("JuliaCon 2024 | REPL Main Stage | Day 2", "https://www.youtube.com/watch?v=Bo3k4oD1Avg")
("JuliaCon 2024 | Function Room | Day 2", "https://www.youtube.com/watch?v=v0RPD4eSzVE")
("JuliaCon 2024 | While Loop Room | Day 2", "https://www.youtube.com/watch?v=PzgFzorRtoo")

("JuliaCon 2024 | REPL Main Stage | Day 3", "https://www.youtube.com/watch?v=t6st0vo0hh4")

("JuliaCon 2024 | Else Room | Day 3", "https://www.youtube.com/watch?v=wqkAz45AdXI")
("JuliaCon 2024 | For Loop Room | Day 3", "https://www.youtube.com/watch?v=f7CLxthbZes")
("JuliaCon 2024 | If Room | Day 3", "https://www.youtube.com/watch?v=Zd33ePxEavc")
("JuliaCon 2024 | While Loop Room | Day 3", "https://www.youtube.com/watch?v=IgFF9JNU9cM")
("JuliaCon 2024 | Method Room | Day 3", "https://www.youtube.com/watch?v=6Te9rThZaa4")
("JuliaCon 2024 | Function Room | Day 3", "https://www.youtube.com/watch?v=qru5G5Yp77E")
]

filenames = map(s-> replace(s[1],"|"=>"_"), vds)
file_name = "/mnt/d/$(filenames[1]).mp4"

nframes = VideoIO.get_number_frames(file_name)
duration = VideoIO.get_duration(file_name)

f = VideoIO.openvideo(file_name)

# iterar sobre todos los frames y calcular la similitud
# iterar sobre los frames skipeando cada 60 y calcular la similitud
#
i0 = read(f)
# xrange, yrange = 440:640, 860:1060
# xrange, yrange = 300:600, 1:500 # REPL d1
# xrange, yrange = 1:144, 1:256# REPL d1
xrange,yrange=150:250,250:400
baseIm = i0[xrange, yrange]
#

using Images

function get_frame_at_sec(i)
  seek(f, i)
  im = read(f)[xrange, yrange]
  im
end

compute(im) =  assess_ssim(baseIm,im)

rango = -300:10:300

get_vals(rango) = map(i-> (i, compute(get_frame_at_sec(i))), rango)

function sec_to_T(sec) 
  h,rh = divrem(sec,3600)
  m,s = divrem(rh, 60)
  (h,m,s)
end


to_second(time, offset_min=10) = Int((time-start_time).value / 1000) + offset_min*60

offset = 60
get_rango(time) = rango .+ to_second(time, offset)

function process(t)
  try
    @info "Procesando" t
    r = get_vals(get_rango(t))
    return (t,r)
  catch
    @warn "No se pudo procesar" t
    return (t,[])
  end
end



function f2(r)
  x = map(s->s[1], r[2])
  y = map(s->s[2], r[2])
  (r[1],x,y)
end


find_peak(res) = res[2][findall( abs.(diff(res[3] .> 0.8)) .> 0 )]


using Printf

function make_comment(talk, peaks)
    peak = isempty(peaks) ? 0 : Int(floor(mean(peaks)))
    h,m,s = sec_to_T(peak)
    m2 = @sprintf "%02d" m
    s2 = @sprintf "%02d" s+2
    "$h:$m2:$s2 - $(talk[:title])" 
end

comment(talks, peaks) = join(map(t->make_comment(t...),zip(talks,peaks)),"\n")

res = map(process, times)
res_split = map(f2, res)
peaks = map(find_peak, res_split)
comment(filtered_talks, peaks) |> clipboard




