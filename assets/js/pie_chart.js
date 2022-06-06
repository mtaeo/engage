import Chart from "chart.js";

class GameStatsPieChart {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "pie",
      data: {
        labels: labels,
        datasets: [
          {
            data: values,
            borderWidth: 2,
            backgroundColor: [
              'rgb(255, 99, 132)',
              'rgb(54, 162, 235)',
              'rgb(255, 205, 86)',
              "#f00",
              "#0f0",
              "#00f"
            ],
            hoverOffset: 4
          },
        ],
      },
    });
  }
}

export default GameStatsPieChart;
