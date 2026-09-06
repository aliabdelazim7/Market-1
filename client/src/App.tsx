import { Route, Switch, Redirect } from 'wouter';
import { StickerAdmin, StickerCustomer } from './pages/StickerSystem';

export default function App() {
  return (
    <Switch>
      <Route path="/stickers/admin"><StickerAdmin /></Route>
      <Route path="/stickers"><StickerCustomer /></Route>
      <Route path="/"><Redirect to="/stickers" /></Route>
      <Route><Redirect to="/stickers" /></Route>
    </Switch>
  );
}
