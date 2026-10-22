import matplotlib.pyplot as plt
import numpy as np


def plot_soal_1():
    x = np.linspace(0, 21, 600)
    y_cpu = 40 - 2 * x
    y_ram = 20 - x / 3

    x_feasible = np.linspace(5, 20, 500)
    y_upper = np.minimum(40 - 2 * x_feasible, 20 - x_feasible / 3)

    plt.figure(figsize=(8, 6))
    plt.plot(x, y_cpu, label="4X1 + 2X2 = 80 (vCPU)")
    plt.plot(x, y_ram, label="2X1 + 6X2 = 120 (RAM)")
    plt.axvline(5, linestyle="--", label="X1 = 5")

    plt.fill_between(
        x_feasible,
        0,
        y_upper,
        where=y_upper >= 0,
        alpha=0.25,
        label="Daerah layak",
    )

    points = [(5, 0), (20, 0), (12, 16), (5, 55 / 3)]
    labels = ["A (5,0)", "B (20,0)", "C (12,16)", "D (5,18.33)"]

    for (px, py), label in zip(points, labels):
        plt.scatter(px, py, s=45)
        plt.annotate(label, (px, py), xytext=(6, 6), textcoords="offset points")

    plt.xlim(0, 21)
    plt.ylim(0, 42)
    plt.xlabel("X1 = Compute-Optimized")
    plt.ylabel("X2 = Memory-Optimized")
    plt.title("Soal 1 — Daerah Layak")
    plt.grid(True, alpha=0.25)
    plt.legend()
    plt.tight_layout()
    plt.savefig("daerah_layak_soal_1.png", dpi=180)
    plt.show()


def plot_soal_2():
    x = np.linspace(0, 12, 600)
    y_research = 12 - 2 * x
    y_prototype = 6 - x / 2

    x_feasible = np.linspace(0, 6, 500)
    y_upper = np.minimum(12 - 2 * x_feasible, 6 - x_feasible / 2)

    plt.figure(figsize=(8, 6))
    plt.plot(x, y_research, label="6X1 + 3X2 = 36 (riset)")
    plt.plot(x, y_prototype, label="4X1 + 8X2 = 48 (prototype)")

    plt.fill_between(
        x_feasible,
        0,
        y_upper,
        where=y_upper >= 0,
        alpha=0.25,
        label="Daerah layak",
    )

    points = [(0, 0), (6, 0), (4, 4), (0, 6)]
    labels = ["A (0,0)", "B (6,0)", "C (4,4)", "D (0,6)"]

    for (px, py), label in zip(points, labels):
        plt.scatter(px, py, s=45)
        plt.annotate(label, (px, py), xytext=(6, 6), textcoords="offset points")

    plt.xlim(0, 12.5)
    plt.ylim(0, 13)
    plt.xlabel("X1 = Proyek UI/UX")
    plt.ylabel("X2 = Proyek Front-End")
    plt.title("Soal 2 — Daerah Layak")
    plt.grid(True, alpha=0.25)
    plt.legend()
    plt.tight_layout()
    plt.savefig("daerah_layak_soal_2.png", dpi=180)
    plt.show()


if __name__ == "__main__":
    plot_soal_1()
    plot_soal_2()
