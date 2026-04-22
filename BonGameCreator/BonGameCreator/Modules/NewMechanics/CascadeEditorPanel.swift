import UIKit

final class CascadeEditorPanel: UIView {

    private(set) var currentConfig = CrystalCascadeConfig()

    private let rowsRow      = CrystalStepperRow()
    private let colsRow      = CrystalStepperRow()
    private let symbolRow    = CrystalStepperRow()
    private let minMatchRow  = CrystalStepperRow()
    private let cascMaxRow   = CrystalStepperRow()
    private let baseMultiSlider  = CrystalSliderRow()
    private let stepMultiSlider  = CrystalSliderRow()

    override init(frame: CGRect) { super.init(frame: frame); setupOrbit() }
    required init?(coder: NSCoder) { super.init(coder: coder); setupOrbit() }

    private func setupOrbit() {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = LumosTheme.Spacing.sm
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        outer.addArrangedSubview(LumosSectionHeader(title: "Cascade Config", accentColor: LumosTheme.Pigment.auroraCyan))

        rowsRow.configure(title: "Grid Rows", value: currentConfig.rows, min: 3, max: 8)
        rowsRow.onValueChanged = { [weak self] v in self?.currentConfig.rows = v }
        outer.addArrangedSubview(rowsRow)

        colsRow.configure(title: "Grid Cols", value: currentConfig.cols, min: 3, max: 8)
        colsRow.onValueChanged = { [weak self] v in self?.currentConfig.cols = v }
        outer.addArrangedSubview(colsRow)

        symbolRow.configure(title: "Symbol Types", value: currentConfig.symbolCount, min: 4, max: 16)
        symbolRow.onValueChanged = { [weak self] v in self?.currentConfig.symbolCount = v }
        outer.addArrangedSubview(symbolRow)

        minMatchRow.configure(title: "Min Match", value: currentConfig.minMatch, min: 3, max: 8)
        minMatchRow.onValueChanged = { [weak self] v in self?.currentConfig.minMatch = v }
        outer.addArrangedSubview(minMatchRow)

        cascMaxRow.configure(title: "Max Cascades", value: currentConfig.maxCascades, min: 3, max: 20)
        cascMaxRow.onValueChanged = { [weak self] v in self?.currentConfig.maxCascades = v }
        outer.addArrangedSubview(cascMaxRow)

        baseMultiSlider.configure(title: "Base Multiplier", value: Float(currentConfig.baseMultiplier),
                                  min: 0.5, max: 5, format: "%.1fx",
                                  accentColor: LumosTheme.Pigment.auroraCyan)
        baseMultiSlider.onValueChanged = { [weak self] v in self?.currentConfig.baseMultiplier = Double(v) }
        outer.addArrangedSubview(baseMultiSlider)

        stepMultiSlider.configure(title: "Cascade Multiplier Step", value: Float(currentConfig.cascadeMultiplierStep),
                                  min: 0.1, max: 2, format: "+%.1fx",
                                  accentColor: LumosTheme.Pigment.auroraViolet)
        stepMultiSlider.onValueChanged = { [weak self] v in self?.currentConfig.cascadeMultiplierStep = Double(v) }
        outer.addArrangedSubview(stepMultiSlider)
    }

    func applyConfig(_ cfg: CrystalCascadeConfig) {
        currentConfig = cfg
        rowsRow.configure(title: "Grid Rows", value: cfg.rows, min: 3, max: 8)
        colsRow.configure(title: "Grid Cols", value: cfg.cols, min: 3, max: 8)
        symbolRow.configure(title: "Symbol Types", value: cfg.symbolCount, min: 4, max: 16)
        minMatchRow.configure(title: "Min Match", value: cfg.minMatch, min: 3, max: 8)
        cascMaxRow.configure(title: "Max Cascades", value: cfg.maxCascades, min: 3, max: 20)
        baseMultiSlider.configure(title: "Base Multiplier", value: Float(cfg.baseMultiplier),
                                  min: 0.5, max: 5, format: "%.1fx", accentColor: LumosTheme.Pigment.auroraCyan)
        stepMultiSlider.configure(title: "Cascade Multiplier Step", value: Float(cfg.cascadeMultiplierStep),
                                  min: 0.1, max: 2, format: "+%.1fx", accentColor: LumosTheme.Pigment.auroraViolet)
    }
}
