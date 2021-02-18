module TriplotGR

using GR,TriplotBase

export tricontour,tricontourf,tripcolor

function tricontour(x,y,z,t,levels)
    contours = TriplotBase.tricontour(x,y,z,t,levels)
    lmin,lmax = extrema(getfield.(contours,:level))
    for c=contours
        GR.setlinecolorind(1000+TriplotBase.getcolorind(c.level,lmin,lmax,256))
        for polyline=c.polylines
            x = first.(polyline)
            y = last.(polyline)
            GR.polyline(x,y)
        end
    end
end

function tricontourf(x,y,z,t,levels)
    filled_contours = TriplotBase.tricontourf(x,y,z,t,levels)
    lmin,lmax = extrema(getfield.(filled_contours,:lower))
    GR.setfillintstyle(1)
    for fc=filled_contours
        x = Float64[]
        y = Float64[]
        for polyline=fc.polylines
            append_with_nan!(x,first.(polyline))
            append_with_nan!(y,last.(polyline))
        end
        GR.setfillcolorind(1000+TriplotBase.getcolorind(fc.lower,lmin,lmax,256))
        GR.fillarea(x,y)
    end
end

function append_with_nan!(a,b)
    append!(a,b)
    push!(a,NaN)
end

function tripcolor(x,y,z,t;zmin=nothing,zmax=nothing,px=nothing,py=nothing)
    _,_,px_dsp,py_dsp = GR.inqdspsize()
    isnothing(px) && (px = px_dsp)
    isnothing(py) && (py = py_dsp)
    cmap = zeros(UInt32,256)
    for i=0:255
        # Pixel is encoded as 0xAABBGGRR,GR.inqcolor returns 0x00BBGGRR,so set opaque
        cmap[begin+i] = 0xff000000 | GR.inqcolor(1000+i)
    end
    img = TriplotBase.tripcolor(x,y,z,t,cmap; px,py,zmin,zmax,yflip=true)
    GR.drawimage(0,1,0,1,size(img,1),size(img,2),img)
end

end
