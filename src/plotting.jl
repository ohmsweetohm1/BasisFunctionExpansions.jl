using RecipesBase
import ColorTypes.HSV

@recipe function f(b::UniformRBFE)
    Nv = size(b.μ,1)
    dist = b.μ[end]-b.μ[1]
    v = range(b.μ[1]-0.1dist, b.μ[end]+0.1dist, length=200)
    seriestype := :line
    color_palette --> [HSV(i,1,0.7) for i in range(0, 255, length=Nv)]
    xguide --> "Scheduling signal \$v\$"
    title --> "Basis function expansion"
    label --> ""
    v, b(v)
end

@recipe function f(rbf::MultiUniformRBFE, style=:default)
    # color_palette --> [HSV(i,1,0.7) for i in range(0, 255, length=Nv)]
    xguide --> "Scheduling signal \$v_1\$"
    yguide --> "Scheduling signal \$v_2\$"
    title --> "Basis function expansion"
    label --> ""
    seriestype --> :surface

    c       = rbf.μ
    minb    = minimum(c,dims=2)
    maxb    = maximum(c,dims=2)
    dist    = maxb-minb
    Npoints = 50
    v = [range(mi, ma, length=Npoints) for (mi,ma) in zip(minb,maxb)]
    vg = meshgrid(v...)
    # v  = plotattributes[:seriestype] == :surface ? vg : v # not really sure what this is for
    if style == :default
        bg = map(vg...) do v1,v2
            maximum(rbf([v1,v2]))
        end
        (v..., bg)
    elseif style == :full
        colorbar --> false
        seriesalpha --> 0.5
        bg = map(vg...) do v1,v2
            rbf([v1,v2])
        end
        bg = cat(bg...,dims=3)
        bg = reshape(bg, size(bg,1), Npoints, Npoints)
        for i = 1:size(bg,1)
            @series (v..., bg[i,:,:])
        end
    end

end
