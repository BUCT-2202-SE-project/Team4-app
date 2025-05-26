export interface ItemType {
  id?:number;
  title?:string | Resource;
  img?:string | Resource;
  url?: string;
}
export interface ItemConfig {
  title: string;
  subtitle?: string; // 可选
  icon?: string |Resource;
  img?: string |Resource; // 可选
  url?: string;
}

export interface TabItem {
  icon: Resource | string;
  iconSelected: Resource | string;
  text: string;
  route: string;
}