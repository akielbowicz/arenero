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

else_d1 = filter(t-> occursin("Else", t[:room]) && occursin("07-10",t[:start]), talks_info )

to_dt(str) = parse(DateTime, split( str, "+02:00")[1], Dates.ISODateTimeFormat)

times = map(t-> to_dt(t[:start]), else_d1)
start_time = floor(times[1], Dates.Hour)

# ####################
using VideoIO
file_name = "JuliaCon 2024 _ Else Room _ Day 1.mp4"

nframes = VideoIO.get_number_frames(file_name)
duration = VideoIO.get_duration(file_name)

f = VideoIO.openvideo(file_name)

# iterar sobre todos los frames y calcular la similitud
# iterar sobre los frames skipeando cada 60 y calcular la similitud
#
i0 = read(f)
baseIm = i0[440:640, 860:1060]
#

using Images

function get_frame_at_sec(i)
  seek(f, i)
  im = read(f)[440:640, 860:1060]
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

get_rango(time) = rango .+ to_second(time)

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

res = map(process, times[emp])


function f2(r)
  x = map(s->s[1], r[2])
  y = map(s->s[2], r[2])
  (r[1],x,y)
end

res_split = map(f2, res)

find_peak(res) = res[2][findall( abs.(diff(res[3] .> 0.8)) .> 0 )]

for (d,p) in zip(else_d1, peaks)
  d[:peaks] = join(p,",")
end


open("my.json", "w") do f
    JSON3.write(f, else_d1)
    println(f)
end

video_link = "https://www.youtube.com/watch?v=LNfSeco0q04&t="

using Printf
function make_comment(talk)
    f = first(split(talk[:peaks],","))
    f = isempty(f) ? "0" : f 
    peak = parse(Int,f)
    h,m,s = sec_to_T(peak)
    m2 = @sprintf "%02d" m
    s2 = @sprintf "%02d" s+2
    "$h:$m2:$s2 - $(talk[:title])" 
end

comment(talks) = join(map(t->make_comment(t),talks),"\n")


comment(video_link, else_d1) |> clipboard