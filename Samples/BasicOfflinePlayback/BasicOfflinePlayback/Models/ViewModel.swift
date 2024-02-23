//
//  ViewModel.swift
//  BasicOfflinePlayback
//
//  Created by Tsung Cheng Lo on 2024/1/5.
//

import Foundation
import BVPlayer

final class ViewModel {
    private var sections: [SourceConfigSection]

    init() {
        sections = []

        let hlsSection = SourceConfigSection(name: "HLS")
        sections.append(hlsSection)

        hlsSection.sourceConfigs.append(createUndercurrent())
        hlsSection.sourceConfigs.append(crateBiriBiri())
    }
    
    private func createUndercurrent() -> UniSourceConfig {
        let sourceUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/d65451ac-f080-42c7-b3e2-746c4ca40fa7/vod/hls.m3u8")!
        let sourceConfig = UniSourceConfig(url: sourceUrl, type: .hls)
        
        sourceConfig.title = "Undercurrent"
        sourceConfig.sourceDescription = "Non DRM"
        sourceConfig.posterSource = URL(string: "https://bitdash-a.akamaihd.net/content/art-of-motion_drm/art-of-motion_poster.jpg")!
        return sourceConfig
    }
    
    private func crateBiriBiri() -> UniSourceConfig {
        let sourceUrl = URL(string: "https://d1kn28obgh8dky.cloudfront.net/7d1e6d5e-6245-43a3-aba0-8e16cf353db5/vod/70d2984e-0327-4da9-bb81-9e35f8b7c8a1/vod/hls.m3u8")!
        let sourceConfig = UniSourceConfig(url: sourceUrl, type: .hls)
        
        sourceConfig.title = "Biri-Biri"
        sourceConfig.sourceDescription = "Non DRM"
        sourceConfig.posterSource = URL(string: "https://bitdash-a.akamaihd.net/content/art-of-motion_drm/art-of-motion_poster.jpg")!
        return sourceConfig
    }

    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        return sections[section].sourceConfigs.count
    }

    func sourceConfigSection(for section: Int) -> SourceConfigSection? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return sections[section]
    }

    func item(for indexPath: IndexPath) -> UniSourceConfig? {
        guard let sourceConfigSection = self.sourceConfigSection(for: indexPath.section),
              sourceConfigSection.sourceConfigs.indices.contains(indexPath.row) else {
            return nil
        }

        return sourceConfigSection.sourceConfigs[indexPath.row]
    }
}

final class SourceConfigSection {
    var name: String
    var sourceConfigs: [UniSourceConfig] = []

    init(name: String) {
        self.name = name
    }
}
