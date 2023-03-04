using GFit, GFitViewer
dom = Domain(0:0.1:5)
model = Model(dom, :bkg => GFit.OffsetSlope(1, 1, 0.1),
                   :l1 => GFit.Gaussian(1, 2, 0.2),
                   :l2 => GFit.Gaussian(1, 3, 0.4),
                   :main => SumReducer(:bkg, :l1, :l2))
model[:bkg].offset.val = 1
model[:bkg].offset.fixed = true

model[:bkg].slope.low  = 0
model[:bkg].slope.high = 0.2
model[:l2].norm.patch = :l1
model[:l2].sigma.patch = @λ m -> 2 * m[:l1].sigma
model[:l2].center.patch = @λ (m, v) -> v + m[:l1].center
model[:l2].center.val = 1   # guess value for the distance between the centers
model[:l2].center.low = 0   # ensure [l2].center > [l1].center
data = GFit.mock(Measures, model)
best, res = fit(model, data)


GFitViewer.serialize_json("gfitviewer_test01.json", best)
GFitViewer.serialize_json("gfitviewer_test02.json", best, res, data)
GFitViewer.serialize_json("gfitviewer_test03.json", rebin=2, best)
GFitViewer.serialize_json("gfitviewer_test04.json", rebin=2, best, res, data,
                          title="Test", xlab="Abscissa", ylab="Ordinate", xr=[0.5, 4.5], yr=[0, 3],
                          xscale=1000, yscale=1e-17, xunit="Angstrom", yunit="erg s^-1 cm^-2 A^-1")




dom = Domain(-5.:0.1:5)
model1 = Model(dom, GFit.Gaussian(1, 0., 1.))
model2 = Model(dom, GFit.Gaussian(1, 0., 1.))
multi = [model1, model2]

# Patch parameters
multi[2][:main].norm.mpatch   = @λ m -> m[1][:main].norm
multi[2][:main].center.mpatch = @λ m -> m[1][:main].center

# Create datasets and fit
data = GFit.mock(Measures, multi)
best, res = fit(multi, data)


meta1 = GFitViewer.Meta(title="First" , xlab="Abscissa", ylab="Ordinate", xr=[-4, 4], rebin=2, xscale=1000, yscale=1e-17, xunit="Angstrom", yunit="erg s^-1 cm^-2 A^-1")
meta2 = GFitViewer.Meta(title="Second", xlab="Abscissa", ylab="Ordinate", xr=[-4, 4], rebin=2, xscale=1000, yscale=1e-17, xunit="Angstrom", yunit="erg s^-1 cm^-2 A^-1")
GFitViewer.serialize_json("gfitviewer_test5.json", multi, xlab="Abscissa", ylab="Ordinate", xr=[-4, 4])
GFitViewer.serialize_json("gfitviewer_test6.json", best, [meta1, meta2])
GFitViewer.serialize_json("gfitviewer_test7.json", best, res, data, [meta1, meta2])
