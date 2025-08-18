import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    @State private var showingAddRepository = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            if viewModel.repositories.isEmpty {
                emptyStateView
            } else {
                repositoryListView
            }
            
            Divider()
            
            footerView
        }
        .frame(width: 350, height: 450)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fileImporter(
            isPresented: $showingAddRepository,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Task {
                        try? await viewModel.addRepository(path: url.path)
                    }
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Image(systemName: "folder.badge.gearshape")
                .font(.title2)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("GitPeek")
                    .font(.headline)
                Text("v1.0.4")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if viewModel.isRefreshing {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Button {
                    Task {
                        await viewModel.refreshAll()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No repositories added")
                .font(.headline)
            
            Text("Add a Git repository to get started")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Add Repository") {
                showingAddRepository = true
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Repository List View
    
    private var repositoryListView: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(viewModel.repositories) { repository in
                    RepositoryRowView(
                        repository: repository,
                        isSelected: viewModel.selectedRepository?.id == repository.id,
                        onSelect: {
                            viewModel.selectRepository(repository)
                        },
                        onOpenInCursor: {
                            viewModel.openInCursor(repository: repository)
                        },
                        onOpenInTerminal: {
                            viewModel.openInTerminal(repository: repository)
                        },
                        onOpenOnGitHub: {
                            viewModel.openOnGitHub(repository: repository)
                        },
                        onCopyBranch: {
                            viewModel.copyBranchName(repository: repository)
                        },
                        onRemove: {
                            viewModel.removeRepository(repository)
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Footer View
    
    private var footerView: some View {
        HStack {
            Button {
                showingAddRepository = true
            } label: {
                Label("Add Repository", systemImage: "plus")
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

// MARK: - Repository Row View

struct RepositoryRowView: View {
    let repository: Repository
    let isSelected: Bool
    let onSelect: () -> Void
    let onOpenInCursor: () -> Void
    let onOpenInTerminal: () -> Void
    let onOpenOnGitHub: () -> Void
    let onCopyBranch: () -> Void
    let onRemove: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            // Repository Info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.accentColor)
                    
                    Text(repository.name)
                        .font(.system(size: 13, weight: .medium))
                    
                    if let branch = repository.currentBranch {
                        Text(branch)
                            .font(.system(size: 11))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                if let status = repository.gitStatus {
                    HStack(spacing: 8) {
                        if !status.stagedFiles.isEmpty {
                            Label("\(status.stagedFiles.count)", systemImage: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if !status.modifiedFiles.isEmpty {
                            Label("\(status.modifiedFiles.count)", systemImage: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(status.modifiedFiles.count == 1 ? .secondary : .orange)
                        }
                        
                        if !status.untrackedFiles.isEmpty {
                            Label("\(status.untrackedFiles.count)", systemImage: "questionmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        if status.isClean {
                            Label("Clean", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            if isHovered {
                HStack(spacing: 4) {
                    Button {
                        onOpenInCursor()
                    } label: {
                        Image(systemName: "cursorarrow.motionlines")
                    }
                    .buttonStyle(.plain)
                    .help("Open in Cursor")
                    
                    Button {
                        onOpenInTerminal()
                    } label: {
                        Image(systemName: "terminal")
                    }
                    .buttonStyle(.plain)
                    .help("Open in Terminal")
                    
                    Menu {
                        Button("Open on GitHub", action: onOpenOnGitHub)
                        Button("Copy Branch Name", action: onCopyBranch)
                        Divider()
                        Button("Remove", action: onRemove)
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : (isHovered ? Color.gray.opacity(0.1) : Color.clear))
        )
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}