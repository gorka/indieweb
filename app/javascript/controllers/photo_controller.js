import { Controller } from "@hotwired/stimulus";
import Swiper from "swiper";
import { Navigation } from "swiper/modules";

// Connects to data-controller="photo"
export default class extends Controller {
  connect() {
    this.swiper = new Swiper(this.element, {
      loop: true,
      modules: [Navigation],
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
    });
  }
}
