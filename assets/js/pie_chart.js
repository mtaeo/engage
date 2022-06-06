import Chart from "chart.js";

class GameStatsPieChart {
  constructor(ctx, labels, values) {
    this.chart = new Chart(ctx, {
      type: "pie",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Test",
            data: values,
            borderColor: "#4c51bf",
          },
        ],
      },
    });
  }
}

export default GameStatsPieChart;
