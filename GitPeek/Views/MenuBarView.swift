import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    @State private var showingSettings = false
    let closePopover: (() -> Void)?
    let openPopover: (() -> Void)?

    init(closePopover: (() -> Void)? = nil, openPopover: (() -> Void)? = nil) {
        self.closePopover = closePopover
        self.openPopover = openPopover
    }
    
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
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PopoverWillShow"))) { _ in
            Task {
                await viewModel.refreshAll()
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            AppIconView(size: 24)

            VStack(alignment: .leading, spacing: 0) {
                Text("GitPeek")
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryText)
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                    .font(.caption2)
                    .foregroundColor(AppTheme.secondaryText)
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
                        .foregroundColor(AppTheme.primaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(AppTheme.headerFooterBackground)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.secondaryText)

            Text("No repositories added")
                .font(.headline)
                .foregroundColor(AppTheme.primaryText)

            Text("Add a Git repository to get started")
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)

            Button("Add Repository") {
                closePopover?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.selectRepositoryFolder {
                        // Reopen popover after repository is added
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            openPopover?()
                        }
                    }
                }
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
                        onOpenInSourceTree: {
                            viewModel.openInSourceTree(repository: repository)
                        },
                        onCopyBranch: {
                            viewModel.copyBranchName(repository: repository)
                        },
                        onRemove: {
                            viewModel.removeRepository(repository)
                        },
                        onPull: {
                            Task {
                                await viewModel.pullRepository(repository)
                            }
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
                closePopover?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.selectRepositoryFolder {
                        // Reopen popover after repository is added
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            openPopover?()
                        }
                    }
                }
            } label: {
                Label("Add Repository", systemImage: "plus")
                    .foregroundColor(AppTheme.primaryText)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(AppTheme.primaryText)
            }
            .buttonStyle(.plain)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .foregroundColor(AppTheme.primaryText)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(AppTheme.headerFooterBackground)
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
    let onOpenInSourceTree: () -> Void
    let onCopyBranch: () -> Void
    let onRemove: () -> Void
    let onPull: () -> Void
    
    @State private var isHovered = false
    @State private var showActions = false
    
    var body: some View {
        HStack {
            // Repository Info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: repository.isWorktree == true ? "folder.badge.questionmark" : "folder")
                        .foregroundColor(.accentColor)
                    
                    Text(repository.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.primaryText)
                    
                    if repository.isWorktree == true {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                    
                    if let branch = repository.currentBranch {
                        HStack(spacing: 4) {
                            Text(branch)
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.branchTagBackground)
                                .cornerRadius(4)
                            
                            // Show commit behind/ahead indicators
                            if let behind = repository.commitsBehind, behind > 0 {
                                Label("\(behind)", systemImage: "arrow.down.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                    .help("\(behind) commits behind origin")
                            }
                            
                            if let ahead = repository.commitsAhead, ahead > 0 {
                                Label("\(ahead)", systemImage: "arrow.up.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                                    .help("\(ahead) commits ahead of origin")
                            }
                        }
                    }
                }
                
                if let status = repository.gitStatus {
                    HStack(spacing: 8) {
                        if !status.stagedFiles.isEmpty {
                            Label("\(status.stagedFiles.count)", systemImage: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.stagedStatus)
                        }
                        
                        if !status.modifiedFiles.isEmpty {
                            Label("\(status.modifiedFiles.count)", systemImage: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(status.modifiedFiles.count == 1 ? AppTheme.secondaryText : AppTheme.modifiedStatus)
                        }
                        
                        if !status.untrackedFiles.isEmpty {
                            Label("\(status.untrackedFiles.count)", systemImage: "questionmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.untrackedStatus)
                        }
                        
                        if status.isClean {
                            Label("Clean", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.cleanStatus)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons - Always visible but with opacity
            HStack(spacing: 2) {
                    Button {
                        onOpenInCursor()
                    } label: {
                        Image(systemName: "cursorarrow.motionlines")
                            .font(.system(size: 12))
                            .frame(width: 24, height: 24)
                            .background(Color.gray.opacity(0.001))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Open in Cursor")
                    
                    Button {
                        onOpenInTerminal()
                    } label: {
                        Image(systemName: "terminal")
                            .font(.system(size: 12))
                            .frame(width: 24, height: 24)
                            .background(Color.gray.opacity(0.001))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Open in Terminal")
                    
                    Menu {
                        if repository.isPulling {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Pulling...")
                            }
                            .disabled(true)
                        } else {
                            Button("Pull Changes", action: onPull)
                                .disabled(repository.commitsBehind == 0 && repository.remoteURL == nil)
                        }

                        Divider()
                        
                        Button("Open on GitHub", action: onOpenOnGitHub)
                        Button("Open in SourceTree", action: onOpenInSourceTree)
                            .disabled(!FileManager.default.fileExists(atPath: "/Applications/SourceTree.app"))
                        Button("Copy Branch Name", action: onCopyBranch)
                        
                        if let worktrees = repository.worktrees, !worktrees.isEmpty {
                            Divider()
                            Menu("Worktrees") {
                                ForEach(worktrees, id: \.path) { worktree in
                                    HStack {
                                        if worktree.isMain {
                                            Label("\(worktree.branch) (main)", systemImage: "star")
                                        } else {
                                            Text(worktree.branch)
                                        }
                                    }
                                    .disabled(true)
                                }
                            }
                        }
                        
                        Divider()
                        Button("Remove", action: onRemove)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 12))
                            .frame(width: 24, height: 24)
                            .background(Color.gray.opacity(0.001))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
            }
            .opacity(isHovered ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? AppTheme.selectedBackground : (isHovered ? AppTheme.hoverBackground : Color.clear))
        )
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - App Icon View

struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        if let path = Bundle.main.path(forResource: "AppIconColor", ofType: "png"),
           let nsImage = NSImage(contentsOfFile: path) {
            Image(nsImage: nsImage)
                .resizable()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: size * 0.7))
                .foregroundColor(.accentColor)
        }
    }
}