import type { App } from 'vue'
import DemoScreen from '../components/DemoScreen.vue'
import '../style.css'

export default ({ app }: { app: App }) => {
  app.component('DemoScreen', DemoScreen)
}
