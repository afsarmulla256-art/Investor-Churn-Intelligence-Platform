"""
=============================================================
  INVESTOR CHURN INTELLIGENCE PLATFORM
  Visualisation Script
  Author  : Afsar Ahamed
  Dataset : 64,374 investor records
  Tools   : Python, Pandas, Matplotlib, Seaborn
=============================================================
  Run: python visualisations.py
  Output: charts/ folder with 8 PNG charts
=============================================================
"""

import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
import numpy as np
import os

# ─── Load Data ───────────────────────────────────────────────────────────────
df = pd.read_csv("investor_churn_powerbi.csv")

# ─── Colour Palette ──────────────────────────────────────────────────────────
NAVY   = "#1E2761"
TEAL   = "#028090"
CORAL  = "#F96167"
GOLD   = "#F9C74F"
AMBER  = "#F4A261"
GRAY   = "#64748B"
WHITE  = "#FFFFFF"

plt.rcParams.update({
    "font.family":        "DejaVu Sans",
    "axes.spines.top":    False,
    "axes.spines.right":  False,
    "axes.facecolor":     WHITE,
    "figure.facecolor":   WHITE,
    "axes.grid":          True,
    "grid.color":         "#E2E8F0",
    "grid.linewidth":     0.6,
})

os.makedirs("charts", exist_ok=True)

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 1 — Overall Churn Donut
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(6, 6), facecolor=WHITE)

churned  = df["Churn"].sum()
active   = len(df) - churned
vals     = [churned, active]
labels   = [f"Churned\n{churned:,}", f"Active\n{active:,}"]
colors   = [CORAL, TEAL]

ax.pie(vals, labels=None, colors=colors, startangle=90,
       wedgeprops={"width": 0.55, "edgecolor": "white", "linewidth": 3})
ax.text(0, 0, f"47.4%\nChurn Rate", ha="center", va="center",
        fontsize=16, fontweight="bold", color=NAVY)

handles = [mpatches.Patch(color=c, label=l) for c, l in zip(colors, labels)]
ax.legend(handles=handles, loc="lower center", ncol=2, frameon=False, fontsize=12)
ax.set_title("Overall Investor Churn Rate", fontsize=16, fontweight="bold",
             color=NAVY, pad=20)

plt.tight_layout()
plt.savefig("charts/01_churn_overview.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 1 — Churn Overview")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 2 — Churn by Contract Length
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5), facecolor=WHITE)

cl = (df.groupby("ContractLength")["Churn"].mean() * 100).sort_values(ascending=False)
bars = ax.bar(cl.index, cl.values, color=[CORAL, GOLD, TEAL],
              width=0.5, edgecolor="white", linewidth=2)

for bar in bars:
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
            f"{bar.get_height():.1f}%", ha="center", va="bottom",
            fontweight="bold", fontsize=12, color=NAVY)

ax.set_ylabel("Churn Rate (%)", color=GRAY)
ax.set_title("Churn Rate by Contract Length", fontsize=15, fontweight="bold", color=NAVY)
ax.set_ylim(0, 65)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/02_churn_by_contract.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 2 — Churn by Contract Length")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 3 — Churn by Tenure Band
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(10, 5), facecolor=WHITE)

order = ["0-12 months", "13-24 months", "25-36 months", "37-48 months", "49-60 months"]
tb = (df.groupby("TenureBand", observed=True)["Churn"]
        .mean().reindex(order) * 100)
colors_tb = [TEAL if v < 40 else GOLD if v < 55 else CORAL for v in tb.values]

bars = ax.bar(range(len(tb)), tb.values, color=colors_tb,
              width=0.6, edgecolor="white", linewidth=2)
ax.set_xticks(range(len(tb)))
ax.set_xticklabels(order, rotation=15, ha="right", color=GRAY)

for bar in bars:
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
            f"{bar.get_height():.1f}%", ha="center", va="bottom",
            fontweight="bold", fontsize=11, color=NAVY)

ax.set_ylabel("Churn Rate (%)", color=GRAY)
ax.set_title("Churn Rate by Investor Tenure", fontsize=15, fontweight="bold", color=NAVY)
ax.set_ylim(0, 70)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/03_churn_by_tenure.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 3 — Churn by Tenure")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 4 — Payment Delay Impact (horizontal bar)
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5), facecolor=WHITE)

order_pd = ["No Delay", "1-10 Days", "11-20 Days", "21+ Days"]
pd_data  = (df.groupby("PaymentDelayBand")["Churn"]
              .mean().reindex(order_pd) * 100)
colors_pd = [TEAL, GOLD, AMBER, CORAL]

bars = ax.barh(order_pd, pd_data.values, color=colors_pd,
               edgecolor="white", linewidth=2, height=0.5)
for bar in bars:
    ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height() / 2,
            f"{bar.get_width():.1f}%", va="center",
            fontweight="bold", fontsize=12, color=NAVY)

ax.set_xlabel("Churn Rate (%)", color=GRAY)
ax.set_title("Payment Delay vs Churn Rate", fontsize=15, fontweight="bold", color=NAVY)
ax.set_xlim(0, 90)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/04_payment_delay_churn.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 4 — Payment Delay Impact")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 5 — Engagement Tier vs Churn (horizontal bar)
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5), facecolor=WHITE)

eng_order = ["Disengaged", "Passively Engaged", "Moderately Engaged", "Highly Engaged"]
eng = (df.groupby("EngagementTier")["Churn"]
         .mean().reindex(eng_order) * 100)
colors_e = [CORAL, AMBER, GOLD, TEAL]

bars = ax.barh(eng_order, eng.values, color=colors_e,
               edgecolor="white", linewidth=2, height=0.5)
for bar in bars:
    ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height() / 2,
            f"{bar.get_width():.1f}%", va="center",
            fontweight="bold", fontsize=12, color=NAVY)

ax.set_xlabel("Churn Rate (%)", color=GRAY)
ax.set_title("Investor Engagement Tier vs Churn", fontsize=15, fontweight="bold", color=NAVY)
ax.set_xlim(0, 90)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/05_engagement_churn.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 5 — Engagement Tier Churn")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 6 — Churn by Subscription Type
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(8, 5), facecolor=WHITE)

sub = (df.groupby("SubscriptionType")["Churn"]
         .mean().sort_values(ascending=False) * 100)
bars = ax.bar(sub.index, sub.values, color=[CORAL, GOLD, TEAL],
              width=0.5, edgecolor="white", linewidth=2)

for bar in bars:
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
            f"{bar.get_height():.1f}%", ha="center", va="bottom",
            fontweight="bold", fontsize=12, color=NAVY)

ax.set_ylabel("Churn Rate (%)", color=GRAY)
ax.set_title("Churn Rate by Subscription Type", fontsize=15, fontweight="bold", color=NAVY)
ax.set_ylim(0, 60)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/06_subscription_churn.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 6 — Subscription Type Churn")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 7 — Cohort Retention Heatmap (Tenure × Contract)
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(10, 5), facecolor=WHITE)

pivot = (df.pivot_table(index="TenureBand", columns="ContractLength",
                        values="Churn", aggfunc="mean", observed=True) * 100)
pivot = pivot.reindex(["0-12 months", "13-24 months", "25-36 months",
                        "37-48 months", "49-60 months"])

sns.heatmap(pivot, annot=True, fmt=".1f", cmap="RdYlGn_r",
            linewidths=0.5, linecolor="white", ax=ax,
            cbar_kws={"label": "Churn Rate (%)", "shrink": 0.8},
            annot_kws={"fontsize": 12, "fontweight": "bold"})

ax.set_title("Cohort Churn Heatmap: Tenure × Contract Type",
             fontsize=14, fontweight="bold", color=NAVY, pad=12)
ax.set_xlabel("Contract Length", color=GRAY)
ax.set_ylabel("Tenure Band", color=GRAY)
ax.tick_params(colors=GRAY, rotation=0)

plt.tight_layout()
plt.savefig("charts/07_cohort_heatmap.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 7 — Cohort Heatmap")

# ─────────────────────────────────────────────────────────────────────────────
#  CHART 8 — Support Calls vs Churn Rate (line chart)
# ─────────────────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(9, 5), facecolor=WHITE)

sc = df.groupby("SupportCalls")["Churn"].mean() * 100
ax.plot(sc.index, sc.values, color=NAVY, linewidth=2.5,
        marker="o", markersize=5, markerfacecolor=CORAL)
ax.fill_between(sc.index, sc.values, alpha=0.1, color=NAVY)

ax.set_xlabel("Number of Support Calls", color=GRAY)
ax.set_ylabel("Churn Rate (%)", color=GRAY)
ax.set_title("Support Calls vs Churn Rate", fontsize=15, fontweight="bold", color=NAVY)
ax.tick_params(colors=GRAY)

plt.tight_layout()
plt.savefig("charts/08_support_calls_churn.png", dpi=150, bbox_inches="tight")
plt.close()
print("✅ Chart 8 — Support Calls vs Churn")

print("\n🎉 All 8 charts saved to charts/ folder")
