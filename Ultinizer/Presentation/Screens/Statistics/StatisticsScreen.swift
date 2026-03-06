import SwiftUI
import Charts

struct StatisticsScreen: View {
    @State private var viewModel: StatisticsViewModel

    @Environment(\.colorScheme) private var colorScheme

    init(container: AppContainer) {
        _viewModel = State(initialValue: StatisticsViewModel(statsRepository: container.statsRepository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Statistics")
                    .font(AppTypography.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, AppSpacing.xl)

                if viewModel.isLoading {
                    VStack {
                        SkeletonView(height: 120)
                        SkeletonView(height: 200).padding(.top, AppSpacing.xl)
                        SkeletonView(height: 200).padding(.top, AppSpacing.xl)
                    }
                } else if let stats = viewModel.stats {
                    // Summary cards
                    HStack(spacing: AppSpacing.lg) {
                        summaryCard(value: "\(Int(stats.completionRate))%", label: "Completion Rate", color: AppColors.magenta500)
                        summaryCard(value: "\(stats.completedTasks)", label: "Completed", color: AppColors.textPrimary)
                        summaryCard(value: "\(stats.totalTasks - stats.completedTasks)", label: "Remaining", color: AppColors.red500)
                    }
                    .padding(.bottom, AppSpacing.xl)

                    // Weekly trend chart
                    if !stats.weeklyTrend.isEmpty {
                        weeklyChart(trend: stats.weeklyTrend)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    // Category breakdown
                    if !stats.byCategory.isEmpty {
                        categoryChart(categories: stats.byCategory)
                            .padding(.bottom, AppSpacing.xl)
                    }

                    // Member contributions
                    if !stats.byMember.isEmpty {
                        memberContributions(members: stats.byMember)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.xl)
            .padding(.bottom, 40)
        }
        .background(AppColors.backgroundSecondary)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadStats()
        }
    }

    // MARK: - Components

    private func summaryCard(value: String, label: String, color: Color) -> some View {
        CardView {
            VStack(spacing: AppSpacing.xs) {
                Text(value)
                    .font(AppTypography.hero)
                    .foregroundColor(color)
                Text(label)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.gray500)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func weeklyChart(trend: [WeeklyTrendItem]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Weekly Completion")
                    .font(AppTypography.bodySemiBold)
                    .foregroundColor(AppColors.textPrimary)

                Chart {
                    ForEach(trend, id: \.date) { item in
                        BarMark(
                            x: .value("Day", shortDayName(item.date)),
                            y: .value("Completed", item.completed)
                        )
                        .foregroundStyle(AppColors.magenta500)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(AppTypography.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel()
                            .font(AppTypography.caption)
                    }
                }
            }
        }
    }

    private func categoryChart(categories: [CategoryStat]) -> some View {
        let colors: [Color] = [AppColors.magenta500, AppColors.blue500, AppColors.green500, AppColors.yellow500, AppColors.red500]

        return CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("By Category")
                    .font(AppTypography.bodySemiBold)
                    .foregroundColor(AppColors.textPrimary)

                Chart {
                    ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, cat in
                        SectorMark(
                            angle: .value("Count", cat.count),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(colors[index % colors.count])
                    }
                }
                .frame(height: 180)

                // Legend
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(categories.enumerated()), id: \.element.categoryId) { index, cat in
                        HStack(spacing: AppSpacing.md) {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 8, height: 8)
                            Text(cat.categoryName)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("\(cat.count)")
                                .font(AppTypography.captionMedium)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private func memberContributions(members: [MemberStat]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Contribution Balance")
                    .font(AppTypography.bodySemiBold)
                    .foregroundColor(AppColors.textPrimary)

                ForEach(members, id: \.userId) { member in
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text(member.displayName)
                                .font(AppTypography.labelMedium)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("\(member.completed) tasks (\(Int(member.percentage))%)")
                                .font(AppTypography.label)
                                .foregroundColor(AppColors.gray500)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: AppRadius.full)
                                    .fill(colorScheme == .dark ? AppColors.gray700 : AppColors.gray200)
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: AppRadius.full)
                                    .fill(AppColors.magenta500)
                                    .frame(width: geometry.size.width * CGFloat(member.percentage) / 100, height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(.bottom, AppSpacing.md)
                }
            }
        }
    }

    private func shortDayName(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
